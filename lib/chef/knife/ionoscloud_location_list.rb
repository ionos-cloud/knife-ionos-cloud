require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudLocationList < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud location list'

      def initialize(args = [])
        super(args)
        @description =
        'List available physical locations where resources can reside.'
        @directory = 'compute-engine'
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        location_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('CPU Architectures', :bold),
        ]
        location_api = Ionoscloud::LocationsApi.new(api_client)

        location_api.locations_get({ depth: 1 }).items.each do |location|
          location_list << location.id
          location_list << location.properties.name
          location_list << location.properties.cpu_architecture.map { |arch| arch.cpu_family }
        end

        puts ui.list(location_list, :uneven_columns_across, 3)
      end
    end
  end
end
