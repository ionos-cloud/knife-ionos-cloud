require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudNetworkloadbalancerRuleList < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud networkloadbalancer rule list (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'The ID of the data center'

      option :network_loadbalancer_id,
              short: '-L NETWORK_LOADBALANCER_ID',
              long: '--network-loadbalancer NETWORK_LOADBALANCER_ID',
              description: 'ID of the Network Loadbalancer'

      def initialize(args = [])
        super(args)
        @description =
        'Lists all available rules in a Network Loadbalancer under a data center.'
        @directory = 'compute-engine'
        @required_options = [:datacenter_id, :network_loadbalancer_id]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        $stdout.sync = true
        handle_extra_config
        network_loadbalancer_rule_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Algorithm', :bold),
          ui.color('Protocol', :bold),
          ui.color('Listener IP', :bold),
          ui.color('Listener Port', :bold),
          ui.color('Targets', :bold),
          ui.color('Health Check', :bold),
        ]
        network_loadbalancers_api = Ionoscloud::NetworkLoadBalancersApi.new(api_client)

        network_loadbalancers_api.datacenters_networkloadbalancers_forwardingrules_get(
          config[:datacenter_id], config[:network_loadbalancer_id], depth: 1,
        ).items.each do |network_loadbalancer_rule|
          network_loadbalancer_rule_list << network_loadbalancer_rule.id
          network_loadbalancer_rule_list << network_loadbalancer_rule.properties.name
          network_loadbalancer_rule_list << network_loadbalancer_rule.properties.algorithm
          network_loadbalancer_rule_list << network_loadbalancer_rule.properties.protocol
          network_loadbalancer_rule_list << network_loadbalancer_rule.properties.listener_ip
          network_loadbalancer_rule_list << network_loadbalancer_rule.properties.listener_port
          network_loadbalancer_rule_list << network_loadbalancer_rule.properties.targets.length
          network_loadbalancer_rule_list << network_loadbalancer_rule.properties.health_check
        end

        puts ui.list(network_loadbalancer_rule_list, :uneven_columns_across, 8)
      end
    end
  end
end
