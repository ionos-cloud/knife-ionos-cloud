require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudNetworkloadbalancerGet < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud networkloadbalancer get (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'ID of the data center'

      option :network_loadbalancer_id,
              short: '-L NETWORK_LOADBALANCER_ID',
              long: '--network-loadbalancer NETWORK_LOADBALANCER_ID',
              description: 'ID of the Network Loadbalancer'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Retrieves the attributes of a given Network Load Balancer.'
        @required_options = [:datacenter_id, :network_loadbalancer_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        print_network_load_balancer(
          Ionoscloud::NetworkLoadBalancersApi.new(api_client).datacenters_networkloadbalancers_find_by_network_load_balancer_id(
            config[:datacenter_id], config[:network_loadbalancer_id], depth: 2,
          ),
        )
      end
    end
  end
end
