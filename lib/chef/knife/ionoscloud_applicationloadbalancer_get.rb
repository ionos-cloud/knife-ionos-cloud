require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudApplicationloadbalancerGet < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud applicationloadbalancer get (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'ID of the data center'

      option :application_loadbalancer_id,
              short: '-L NETWORK_LOADBALANCER_ID',
              long: '--application-loadbalancer NETWORK_LOADBALANCER_ID',
              description: 'ID of the Application Loadbalancer'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Retrieves the attributes of a given Application Load Balancer.'
        @required_options = [:datacenter_id, :application_loadbalancer_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        application_load_balancers_api = Ionoscloud::ApplicationLoadBalancersApi.new(api_client)

        print_application_loadbalancer(application_load_balancers_api.datacenters_applicationloadbalancers_find_by_application_load_balancer_id(
                                         config[:datacenter_id], config[:application_loadbalancer_id], depth: 2,
        ))
      end
    end
  end
end
