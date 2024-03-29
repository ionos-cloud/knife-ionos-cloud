require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudServerDelete < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud server delete SERVER_ID [SERVER_ID] (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'Name of the data center'

      def initialize(args = [])
        super(args)
        @description =
        "This will remove a server from a VDC.\n\n"\
        '**NOTE**: This will not automatically remove the storage volume\\(s\\) '\
        'attached to a server. A separate API call is required to perform that action.'
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
            server = server_api.datacenters_servers_find_by_id(config[:datacenter_id], server_id)
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("Server ID #{server_id} not found. Skipping.")
            next
          end

          print_server(server)
          puts "\n"

          begin
            confirm('Do you really want to delete this server')
          rescue SystemExit
            next
          end

          _, _, headers = server_api.datacenters_servers_delete_with_http_info(config[:datacenter_id], server_id)
          ui.warn("Deleted Server #{server.id}. Request ID: #{get_request_id headers}")
        end
      end
    end
  end
end
