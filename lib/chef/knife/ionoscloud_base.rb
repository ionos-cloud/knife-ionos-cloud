require 'chef/knife'

class Chef
  class Knife
    module IonoscloudBase
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
        end
      end

      def msg_pair(label, value, color = :cyan)
        if !value.nil? && !value.to_s.empty?
          puts "#{ui.color(label, color)}: #{value}"
        end
      end

      def validate_required_params(required_params, params)
        missing_params = required_params.select do |param|
          params[param].nil?
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

      def get_target_group_extended_properties(target_group)
        health_check = target_group.properties.health_check.nil? ? nil : {
          check_timeout: target_group.properties.health_check.check_timeout,
          connect_timeout: target_group.properties.health_check.connect_timeout,
          target_timeout: target_group.properties.health_check.target_timeout,
          retries: target_group.properties.health_check.retries,
        }
        http_health_check = target_group.properties.http_health_check.nil? ? nil : {
          path: target_group.properties.http_health_check.path,
          method: target_group.properties.http_health_check.method,
          match_type: target_group.properties.http_health_check.match_type,
          response: target_group.properties.http_health_check.response,
          regex: target_group.properties.http_health_check.regex,
          negate: target_group.properties.http_health_check.negate,
        }
        targets = target_group.properties.targets.nil? ? [] : target_group.properties.targets.map do
          |target|
          {
            ip: target.ip,
            port: target.port,
            weight: target.weight,
            health_check: target.health_check.nil? ? nil : {
              check: target.health_check.check,
              check_interval: target.health_check.check_interval,
              maintenance: target.health_check.maintenance,
            },
          }
        end

        return health_check, http_health_check, targets
      end

      def print_target_group(target_group)
        health_check, http_health_check, targets = get_target_group_extended_properties(target_group)

        puts "\n"
        puts "#{ui.color('ID', :cyan)}: #{target_group.id}"
        puts "#{ui.color('Name', :cyan)}: #{target_group.properties.name}"
        puts "#{ui.color('Algorithm', :cyan)}: #{target_group.properties.algorithm}"
        puts "#{ui.color('Protocol', :cyan)}: #{target_group.properties.protocol}"
        puts "#{ui.color('Health Check', :cyan)}: #{health_check}"
        puts "#{ui.color('HTTP Health Check', :cyan)}: #{http_health_check}"
        puts "#{ui.color('Targets', :cyan)}: #{targets}"
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
