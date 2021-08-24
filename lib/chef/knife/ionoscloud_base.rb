require 'chef/knife'

class Chef
  class Knife
    module IonoscloudBase
      def initialize(args = [])
        super(args)
        @description = ''
        @required_options = []
      end

      def self.included(includer)
        includer.class_eval do
          deps do
            require 'ionoscloud'
          end

          option :ionoscloud_username,
                  short: '-u USERNAME',
                  long: '--username USERNAME',
                  description: 'Your Ionoscloud username'

          option :ionoscloud_password,
                  short: '-p PASSWORD',
                  long: '--password PASSWORD',
                  description: 'Your Ionoscloud password'

          option :extra_config_file,
                  short: '-e EXTRA_CONFIG_FILE',
                  long: '--extra-config EXTRA_CONFIG_FILE',
                  description: 'Additional config file name'
        end
      end

      def msg_pair(label, value, color = :cyan)
        if !value.nil? && !value.to_s.empty?
          puts "#{ui.color(label, color)}: #{value}"
        end
      end

      def handle_extra_config
        return if config[:extra_config_file].nil?
        JSON[File.read(config[:extra_config_file])].transform_keys(&:to_sym).each do |key, value|
          config[key] = value unless config.key?(key)
        end
      end

      def validate_required_params
        missing_params = @required_options.select do |param|
          config[param].nil?
        end
        if missing_params.any?
          puts "Missing required parameters #{missing_params}"
          exit(1)
        end
      end

      def api_client
        api_config = Ionoscloud::Configuration.new()

        api_config.username = config[:ionoscloud_username]
        api_config.password = config[:ionoscloud_password]

        api_config.debugging = config[:ionoscloud_debug] || false

        @api_client ||= Ionoscloud::ApiClient.new(api_config)
      end

      def get_request_id(headers)
        begin
          headers['Location'].scan(%r{/requests/(\b[0-9a-f]{8}\b-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-\b[0-9a-f]{12}\b)}).last.first
        rescue NoMethodError
          nil
        end
      end

      def is_done?(request_id)
        response = Ionoscloud::RequestsApi.new(api_client).requests_status_get(request_id)
        if response.metadata.status == 'FAILED'
          puts "\nRequest #{request_id} failed\n#{response.metadata.message.to_s}"
          exit(1)
        end
        response.metadata.status == 'DONE'
      end

      def get_application_loadbalancer_extended_properties(application_loadbalancer)
        application_loadbalancer.entities.forwardingrules.items.map do |rule|
          {
            id: rule.id,
            name: rule.properties.name,
            protocol: rule.properties.protocol,
            listener_ip: rule.properties.listener_ip,
            listener_port: rule.properties.listener_port,
            health_check: rule.properties.health_check.nil? ? nil : {
              client_timeout: rule.properties.health_check.client_timeout,
            },
            server_certificates: rule.properties.server_certificates,
            http_rules: rule.properties.http_rules.nil? ? [] : rule.properties.http_rules.map do |http_rule|
              {
                name: http_rule.name,
                type: http_rule.type,
                target_group: http_rule.target_group,
                drop_query: http_rule.drop_query,
                location: http_rule.location,
                status_code: http_rule.status_code,
                response_message: http_rule.response_message,
                content_type: http_rule.content_type,
                conditions: http_rule.conditions.nil? ? [] : http_rule.conditions.map do |condition|
                  {
                    type: condition.type,
                    condition: condition.condition,
                    negate: condition.negate,
                    key: condition.key,
                    value: condition.value,
                  }
                end
              }
            end
          }
        end
      end

      def print_application_loadbalancer(application_loadbalancer)
        rules = get_application_loadbalancer_extended_properties(application_loadbalancer)

        puts "\n"
        puts "#{ui.color('ID', :cyan)}: #{application_loadbalancer.id}"
        puts "#{ui.color('Name', :cyan)}: #{application_loadbalancer.properties.name}"
        puts "#{ui.color('Listener LAN', :cyan)}: #{application_loadbalancer.properties.listener_lan}"
        puts "#{ui.color('Target LAN', :cyan)}: #{application_loadbalancer.properties.target_lan}"
        puts "#{ui.color('IPS', :cyan)}: #{application_loadbalancer.properties.ips}"
        puts "#{ui.color('Lb Private IPS', :cyan)}: #{application_loadbalancer.properties.lb_private_ips}"
        puts "#{ui.color('Rules', :cyan)}: #{rules}"
        puts 'done'
      end
    end
  end
end

# compact method will remove nil values from Hash
class Hash
  def compact
    delete_if { |_k, v| v.nil? }
  end
end
