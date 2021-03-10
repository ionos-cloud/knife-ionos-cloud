require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudVolumeAttach < Knife
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

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'This will attach a pre-existing storage volume to the server.'
        @required_options = [:datacenter_id, :server_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        validate_required_params(@required_options, config)

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
