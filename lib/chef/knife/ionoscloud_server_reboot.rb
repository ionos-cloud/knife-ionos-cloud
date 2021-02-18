require 'chef/knife/ionoscloud_base'

class Chef
  class Knife
    class IonoscloudServerReboot < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud server reboot SERVER_ID [SERVER_ID] (options)'

      option :datacenter_id,
             short: '-D DATACENTER_ID',
             long: '--datacenter-id DATACENTER_ID',
             description: 'ID of the data center'

      attr_reader :description, :required_options

      def initialize(args=[])
        super(args)
        @description =
        'This will force a hard reboot of the server. Do not use this method '\
        'if you want to gracefully reboot the machine. This is the equivalent '\
        'of powering off the machine and turning it back on.'
        @required_options = [:datacenter_id]
      end

      def run
        server_api = Ionoscloud::ServerApi.new(api_client)

        @name_args.each do |server_id|
          begin
            _, _, headers = server_api.datacenters_servers_reboot_post_with_http_info(config[:datacenter_id], server_id)
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("Server ID #{server_id} not found. Skipping.")
            next
          end
          ui.warn("Server #{server_id} is rebooting. Request ID: #{get_request_id headers}")
        end
      end
    end
  end
end
