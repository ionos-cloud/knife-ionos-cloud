require 'chef/knife/profitbricks_base'

class Chef
  class Knife
    class ProfitbricksVolumeDelete < Knife
      include Knife::ProfitbricksBase

      banner 'knife profitbricks volume delete SERVER_ID [SERVER_ID] (options)'

      option :datacenter_id,
             short: '-D ID',
             long: '--datacenter-id ID',
             description: 'Name of the data center'

      def run
        volume_api = Ionoscloud::VolumeApi.new(api_client)

        @name_args.each do |volume_id|
          begin
            volume = volume_api.datacenters_volumes_find_by_id(
              config[:datacenter_id], 
              volume_id,
            )
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("Volume ID #{volume_id} not found. Skipping.")
            next
          end

          msg_pair('ID', volume.id)
          msg_pair('Name', volume.properties.name)
          msg_pair('Size', volume.properties.size)
          msg_pair('Bus', volume.properties.bus)
          msg_pair('Image', volume.properties.image)

          begin
            confirm('Do you really want to delete this volume')
          rescue SystemExit => exc
            next
          end

          _, _, headers = volume_api.datacenters_volumes_delete_with_http_info(
            config[:datacenter_id], 
            volume_id,
          )
          ui.warn("Deleted Volume #{volume.id}. Request ID: #{get_request_id headers}")
        end
      end
    end
  end
end
