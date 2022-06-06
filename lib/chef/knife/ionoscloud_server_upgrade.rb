require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudServerUpgrade < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud server upgrade (options)'

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
        'This will upgrade the version of the server, if needed. To verify if there is an upgrade available for a server, '\
        "call '/datacenters/{datacenterId}/servers?upgradeNeeded=true'."
        @directory = 'compute-engine'
        @required_options = [:datacenter_id, :server_id]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        begin
          _, _, headers = Ionoscloud::ServersApi.new(api_client).datacenters_servers_upgrade_post(config[:datacenter_id], config[:server_id])
          ui.info("Server #{config[:server_id]} is being upgraded. Request ID: #{get_request_id headers}")
        rescue Ionoscloud::ApiError => err
          raise err unless err.code == 404
          ui.error("Server ID #{config[:server_id]} not found.")
        end
      end
    end
  end
end
