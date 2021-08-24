require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudServerStart < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud server start SERVER_ID [SERVER_ID] (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'ID of the data center'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'This will start a server. If the server\'s public IP was deallocated then a new IP will be assigned.'
        @required_options = [:datacenter_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        validate_required_params

        server_api = Ionoscloud::ServersApi.new(api_client)

        @name_args.each do |server_id|
          begin
            _, _, headers = server_api.datacenters_servers_start_post_with_http_info(config[:datacenter_id], server_id)
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("Server ID #{server_id} not found. Skipping.")
            next
          end
          ui.info("Server #{server_id} is starting. Request ID: #{get_request_id headers}")
        end
      end
    end
  end
end
