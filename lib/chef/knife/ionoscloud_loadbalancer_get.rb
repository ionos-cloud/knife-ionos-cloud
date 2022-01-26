require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudLoadbalancerGet < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud loadbalancer get (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'ID of the data center'

      option :loadbalancer_id,
              short: '-L LOADBALANCER_ID',
              long: '--loadbalancer-id LOADBALANCER_ID',
              description: 'ID of the load balancer'

      def initialize(args = [])
        super(args)
        @description =
        'Retrieves the attributes of a given load balancer. This will also retrieve a list of NICs associated with the load balancer.'
        @directory = 'compute-engine'
        @required_options = [:datacenter_id, :loadbalancer_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        load_balancer_api = Ionoscloud::LoadBalancersApi.new(api_client)

        print_load_balancer(
          load_balancer_api.datacenters_loadbalancers_find_by_id(config[:datacenter_id], config[:loadbalancer_id], depth: 1),
        )
      end
    end
  end
end
