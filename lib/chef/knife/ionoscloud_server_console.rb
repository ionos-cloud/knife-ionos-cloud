require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudServerConsole < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud server console (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'The ID of the Datacenter.'

      option :server_id,
              short: '-S SERVER_ID',
              long: '--server-id SERVER_ID',
              description: 'The ID of the Server.'

      def initialize(args = [])
        super(args)
        @description =
        'Returns the link with the jwToken to access the server remote console.'
        @directory = 'compute-engine'
        @required_options = [:datacenter_id, :server_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        begin
          puts Ionoscloud::ServersApi.new(api_client).datacenters_servers_remote_console_get(config[:datacenter_id], config[:server_id]).url
        rescue Ionoscloud::ApiError => err
          raise err unless err.code == 404
          ui.error("Server ID #{config[:server_id]} not found.")
        end
      end
    end
  end
end
