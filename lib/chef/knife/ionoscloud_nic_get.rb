require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudNicGet < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud nic get (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'ID of the data center'

      option :server_id,
              short: '-S SERVER_ID',
              long: '--server-id SERVER_ID',
              description: 'The ID of the server to which the NIC is assigned'

      option :nic_id,
              short: '-N NIC_ID',
              long: '--nic-id NIC_ID',
              description: 'ID of the load balancer'

      def initialize(args = [])
        super(args)
        @description =
        'Retrieves the attributes of a given NIC.'
        @directory = 'compute-engine'
        @required_options = [:datacenter_id, :server_id, :nic_id]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        print_nic(
          Ionoscloud::NetworkInterfacesApi.new(api_client).datacenters_servers_nics_find_by_id(
            config[:datacenter_id],
            config[:server_id],
            config[:nic_id],
          ),
        )
      end
    end
  end
end
