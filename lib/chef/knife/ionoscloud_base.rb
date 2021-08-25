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

      def validate_required_params(required_params, params)
        missing_params = required_params.select do |param|
          params[param].nil?
        end
        if missing_params.any?
          puts "Missing required parameters #{missing_params}"
          exit(1)
        end
      end

      def handle_extra_config
        return if config[:extra_config_file].nil?

        available_options = options.map { |key, _| key }
        ionoscloud_options = available_options[available_options.find_index(:ionoscloud_username)..]
        ignored_options = []

        JSON[File.read(config[:extra_config_file])].transform_keys(&:to_sym).each do |key, value|
          if config.key?(key) || !ionoscloud_options.include?(key)
            ignored_options << key
          else
            config[key] = value 
          end
        end

        ui.warn "The following options #{ignored_options} from the specified JSON file will be ignored." unless ignored_options.empty?
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
        response = Ionoscloud::RequestApi.new(api_client).requests_status_get(request_id)
        if response.metadata.status == 'FAILED'
          puts "\nRequest #{request_id} failed\n#{response.metadata.message.to_s}"
          exit(1)
        end
        response.metadata.status == 'DONE'
      end

      def print_datacenter(datacenter)
        print "\n"
        puts "#{ui.color('ID', :cyan)}: #{datacenter.id}"
        puts "#{ui.color('Name', :cyan)}: #{datacenter.properties.name}"
        puts "#{ui.color('Description', :cyan)}: #{datacenter.properties.description}"
        puts "#{ui.color('Location', :cyan)}: #{datacenter.properties.location}"
        puts "#{ui.color('Version', :cyan)}: #{datacenter.properties.version}"
        puts "#{ui.color('Features', :cyan)}: #{datacenter.properties.features}"
        puts "#{ui.color('Sec Auth Protection', :cyan)}: #{datacenter.properties.sec_auth_protection}"
      end

      def print_backupunit(backupunit)
        print "\n"
        puts "#{ui.color('ID', :cyan)}: #{backupunit.id}"
        puts "#{ui.color('Name', :cyan)}: #{backupunit.properties.name}"
        puts "#{ui.color('Email', :cyan)}: #{backupunit.properties.email}"
      end

      def print_firewall_rule(firewall)
        print "\n"
        puts "#{ui.color('ID', :cyan)}: #{firewall.id}"
        puts "#{ui.color('Name', :cyan)}: #{firewall.properties.name}"
        puts "#{ui.color('Protocol', :cyan)}: #{firewall.properties.protocol}"
        puts "#{ui.color('Source MAC', :cyan)}: #{firewall.properties.source_mac}"
        puts "#{ui.color('Source IP', :cyan)}: #{firewall.properties.source_ip}"
        puts "#{ui.color('Target IP', :cyan)}: #{firewall.properties.target_ip}"
        puts "#{ui.color('Port Range Start', :cyan)}: #{firewall.properties.port_range_start}"
        puts "#{ui.color('Port Range End', :cyan)}: #{firewall.properties.port_range_end}"
        puts "#{ui.color('ICMP Type', :cyan)}: #{firewall.properties.icmp_type}"
        puts "#{ui.color('ICMP Code', :cyan)}: #{firewall.properties.icmp_code}"
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
