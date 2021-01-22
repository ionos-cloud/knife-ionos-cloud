require 'chef/knife/profitbricks_base'

class Chef
  class Knife
    class ProfitbricksVolumeAttach < Knife
      include Knife::ProfitbricksBase

      banner 'knife profitbricks volume attach VOLUME_ID [VOLUME_ID] (options)'

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
        volume_api = Ionoscloud::VolumeApi.new(api_client)

        @name_args.each do |volume_id|
          begin
            volume = volume_api.datacenters_volumes_find_by_id(
              config[:datacenter_id], volume_id, default_opts,
            )
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("Volume ID #{datacenter_id} not found. Skipping.")
            next
          end
          puts volume.to_hash
          server_api.datacenters_servers_volumes_post(
            config[:datacenter_id],
            config[:server_id],
            {'id' => volume_id},
            default_opts)

          ui.msg("Volume #{volume_id} attached to server")
        end
      end
    end
  end
end
