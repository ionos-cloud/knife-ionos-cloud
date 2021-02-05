require 'chef/knife/ionoscloud_base'

class Chef
  class Knife
    class ProfitbricksLocationList < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud location list'

      def run
        $stdout.sync = true
        location_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold)
        ]
        location_api = Ionoscloud::LocationApi.new(api_client)

        location_api.locations_get({ depth: 1 }).items.each do |location|
          location_list << location.id
          location_list << location.properties.name
        end

        puts ui.list(location_list, :uneven_columns_across, 2)
      end
    end
  end
end
