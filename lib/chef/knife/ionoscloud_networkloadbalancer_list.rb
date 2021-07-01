require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudNetworkloadbalancerList < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud networkloadbalancer list (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'Name of the data center'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Retrieve a list of Network Load Balancers within the datacenter.'
        @required_options = [:datacenter_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        validate_required_params(@required_options, config)

        network_load_balancers_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Listener LAN', :bold),
          ui.color('Target LAN', :bold),
          ui.color('Rules', :bold),
          ui.color('Flowlogs', :bold),
          ui.color('IPS', :bold),
          ui.color('Private IPS', :bold),
        ]

        network_load_balancers_api = Ionoscloud::NetworkLoadBalancersApi.new(api_client)

        network_load_balancers_api.datacenters_networkloadbalancers_get(config[:datacenter_id], { depth: 2 }).items.each do |network_load_balancer|
          network_load_balancers_list << network_load_balancer.id
          network_load_balancers_list << network_load_balancer.properties.name
          network_load_balancers_list << network_load_balancer.properties.listener_lan
          network_load_balancers_list << network_load_balancer.properties.target_lan
          network_load_balancers_list << network_load_balancer.entities.forwardingrules.items.length
          network_load_balancers_list << network_load_balancer.entities.flowlogs.items.length
          network_load_balancers_list << network_load_balancer.properties.ips
          network_load_balancers_list << network_load_balancer.properties.lb_private_ips
        end

        puts ui.list(network_load_balancers_list, :uneven_columns_across, 8)
      end
    end
  end
end
