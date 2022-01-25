require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudServerStop < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud server stop SERVER_ID [SERVER_ID] (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'ID of the data center'

      def initialize(args = [])
        super(args)
        @description =
        'This will stop a server. The machine will be forcefully powered off, '\
        'billing will cease, and the public IP, if one is allocated, will be deallocated.'
        @directory = 'compute-engine'
        @required_options = [:datacenter_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        server_api = Ionoscloud::ServersApi.new(api_client)

        @name_args.each do |server_id|
          begin
            _, _, headers = server_api.datacenters_servers_stop_post_with_http_info(config[:datacenter_id], server_id)
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("Server ID #{server_id} not found. Skipping.")
            next
          end
          ui.warn("Server #{server_id} is stopping. Request ID: #{get_request_id headers}")
        end
      end
    end
  end
end
