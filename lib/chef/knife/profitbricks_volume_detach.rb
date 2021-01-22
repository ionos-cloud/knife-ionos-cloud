require 'chef/knife/profitbricks_base'

class Chef
  class Knife
    class ProfitbricksVolumeDetach < Knife
      include Knife::ProfitbricksBase

      banner 'knife profitbricks volume detach VOLUME_ID [VOLUME_ID] (options)'

      option :datacenter_id,
             short: '-D DATACENTER_ID',
             long: '--datacenter-id DATACENTER_ID',
             description: 'The ID of the data center'

      option :server_id,
             short: '-S SERVER_ID',
             long: '--server-id SERVER_ID',
             description: 'The ID of the server'

      def run
        validate_required_params(%i(datacenter_id server_id), config)
        server_api = Ionoscloud::ServerApi.new(api_client)

        @name_args.each do |volume_id|
          begin
            volume = server_api.datacenters_servers_volumes_find_by_id(
              config[:datacenter_id],
              config[:server_id],
              volume_id,
              default_opts,
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
          msg_pair('Device Number', volume.properties.device_number)

          begin
            confirm('Do you really want to detach this volume')
          rescue SystemExit => exc
            next
          end

          server_api.datacenters_servers_volumes_delete(
            config[:datacenter_id],
            config[:server_id],
            volume.id,
            default_opts,
          )

          ui.msg("Detaching volume #{volume_id} from server")
        end
      end
    end
  end
end
