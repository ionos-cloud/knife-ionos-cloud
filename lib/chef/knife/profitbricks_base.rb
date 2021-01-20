require 'chef/knife'
require 'knife-profitbricks/version'

class Chef
  class Knife
    module ProfitbricksBase
      def self.included(includer)
        includer.class_eval do
          deps do
            require 'ionoscloud'
          end

          option :profitbricks_username,
            short: '-u USERNAME',
            long: '--username USERNAME',
            description: 'Your ProfitBricks username'

          option :profitbricks_password,
            short: '-p PASSWORD',
            long: '--password PASSWORD',
            description: 'Your ProfitBricks password'

          option :profitbricks_url,
            short: '-U URL',
            long: '--url URL',
            description: 'The ProfitBricks API URL'
        end
      end

      def connection
        ProfitBricks.configure do |config|
          config.username = Chef::Config[:knife][:profitbricks_username]
          config.password = Chef::Config[:knife][:profitbricks_password]
          config.url = Chef::Config[:knife][:profitbricks_url]
          config.debug = Chef::Config[:knife][:profitbricks_debug] || false
          config.global_classes = false
          config.headers = Hash.new
          config.headers['User-Agent'] = "Chef/#{::Chef::VERSION} knife-profitbricks/#{::Knife::ProfitBricks::VERSION}"
        end
      end

      def msg_pair(label, value, color = :cyan)
        if value && !value.to_s.empty?
          puts "#{ui.color(label, color)}: #{value}"
        end
      end


      def get_image(image_name, image_type, image_location)
        images = ProfitBricks::Image.list
        min_image = nil
        images.each do |image|
          if image.properties['name'].downcase.include? image_name && image.properties['public'] == true && image.properties['imageType'] == image_type && image.properties['location'] == image_location
            min_image = image
          end
        end
        min_image
      end

      def validate_required_params(required_params, params)
        missing_params = required_params.select do |param|
           params[param].nil?
         end
        if missing_params.any?
          ui.error "Missing required parameters #{missing_params}"
          exit(1)
        end
      end

      def api_client
        api_config = Ionoscloud::Configuration.new()

        api_config.username = config[:profitbricks_username]
        api_config.password = config[:profitbricks_password]

        api_config.debugging= config[:profitbricks_debug] || false

        Ionoscloud::ApiClient.new(api_config)
      end

      def default_opts
        {:debug_auth_names => ['Basic Authentication']}
      end

      def is_done? request_id
        Ionoscloud::RequestApi.new(api_client).requests_status_get(request_id, default_opts).metadata.status == 'DONE'
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
