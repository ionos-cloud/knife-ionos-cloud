require 'chef/knife/ionoscloud_base'

class Chef
  class Knife
    class IonoscloudDatacenterList < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud datacenter list'

      def run
        $stdout.sync = true
        datacenter_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Description', :bold),
          ui.color('Location', :bold),
          ui.color('Version', :bold)
        ]

        datacenter_api = Ionoscloud::DataCenterApi.new(api_client)

        datacenter_api.datacenters_get({ depth: 1 }).items.each do |datacenter|
          datacenter_list << datacenter.id
          datacenter_list << datacenter.properties.name
          datacenter_list << datacenter.properties.description || ''
          datacenter_list << datacenter.properties.location
          datacenter_list << datacenter.properties.version.to_s
        end

        puts ui.list(datacenter_list, :uneven_columns_across, 5)
      end
    end
  end
end
