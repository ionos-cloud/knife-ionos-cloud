require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudServerSuspend < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud server suspend SERVER_ID [SERVER_ID] (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'ID of the data center'

      def initialize(args = [])
        super(args)
        @description =
        'This will suspend a server. The operation can only be applied to Cube servers. '\
        'Note: The virtual machine will not be deleted, and the consumed resources will continue to be billed.'
        @directory = 'compute-engine'
        @required_options = [:datacenter_id]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        server_api = Ionoscloud::ServersApi.new(api_client)

        @name_args.each do |server_id|
          begin
            _, _, headers = server_api.datacenters_servers_suspend_post_with_http_info(config[:datacenter_id], server_id)
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("Server ID #{server_id} not found. Skipping.")
            next
          end
          ui.warn("Server #{server_id} is being suspended. Request ID: #{get_request_id headers}")
        end
      end
    end
  end
end
