require 'chef/knife/profitbricks_base'

class Chef
  class Knife
    class ProfitbricksVolumeList < Knife
      include Knife::ProfitbricksBase

      banner 'knife profitbricks volume list (options)'

      option :datacenter_id,
             short: '-D DATACENTER_ID',
             long: '--datacenter-id DATACENTER_ID',
             description: 'The ID of the virtul data center containing the volume'

      option :server_id,
             short: '-S SERVER_ID',
             long: '--server-id SERVER_ID',
             description: 'The ID of the server'

      def run
        $stdout.sync = true
        volume_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Size', :bold),
          ui.color('Bus', :bold),
          ui.color('Image', :bold),
          ui.color('Type', :bold),
          ui.color('Zone', :bold),
          ui.color('Device Number', :bold)
        ]

        opts = default_opts.update({
          :depth => 1,
        })

        if config[:server_id]
          server_api = Ionoscloud::ServerApi.new(api_client)
          volumes = server_api.datacenters_servers_volumes_get(config[:datacenter_id], config[:server_id], opts)

          volumes.items.each do |volume|
            volume_list << volume.id
            volume_list << volume.properties.name
            volume_list << volume.properties.size.to_s
            volume_list << volume.properties.bus
            volume_list << volume.properties.image
            volume_list << volume.properties.type
            volume_list << volume.properties.availability_zone
            volume_list << volume.properties.device_number.to_s
          end
        else
          volume_api = Ionoscloud::VolumeApi.new(api_client)
          volumes = volume_api.datacenters_volumes_get(config[:datacenter_id], opts)

          volumes.items.each do |volume|
            volume_list << volume.id
            volume_list << volume.properties.name
            volume_list << volume.properties.size.to_s
            volume_list << volume.properties.bus
            volume_list << volume.properties.image
            volume_list << volume.properties.type
            volume_list << volume.properties.availability_zone
            volume_list << volume.properties.device_number.to_s
          end
        end

        puts ui.list(volume_list, :uneven_columns_across, 8)
      end
    end
  end
end
