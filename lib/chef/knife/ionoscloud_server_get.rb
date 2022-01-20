require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudServerGet < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud server get (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'ID of the data center'

      option :server_id,
              short: '-S SERVER_ID',
              long: '--server-id SERVER_ID',
              description: 'The ID of the server to which the NIC is assigned'

      def initialize(args = [])
        super(args)
        @description =
        'Retrieves the attributes of a given Server.'
        @directory = 'compute-engine'
        @required_options = [:datacenter_id, :server_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)\

        print_server(
          Ionoscloud::ServersApi.new(api_client).datacenters_servers_find_by_id(
            config[:datacenter_id],
            config[:server_id],
          ),
        )
      end
    end
  end
end
