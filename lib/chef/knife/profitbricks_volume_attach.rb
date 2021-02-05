require 'chef/knife/ionoscloud_base'

class Chef
  class Knife
    class ProfitbricksVolumeAttach < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud volume attach VOLUME_ID [VOLUME_ID] (options)'

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
            _, _, headers = server_api.datacenters_servers_volumes_post_with_http_info(
              config[:datacenter_id],
              config[:server_id],
              { id: volume_id },
            )
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("Volume ID #{volume_id} not found. Skipping.")
            next
          end
          ui.msg("Volume #{volume_id} attached to server. Request ID: #{get_request_id headers}")
        end
      end
    end
  end
end
