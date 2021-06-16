require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudNetworkloadbalancerRuleTargetList < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud networkloadbalancer rule target list (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'The ID of the data center'

      option :network_loadbalancer_id,
              short: '-L NETWORK_LOADBALANCER_ID',
              long: '--network-loadbalancer NETWORK_LOADBALANCER_ID',
              description: 'ID of the Network Loadbalancer'

      option :forwarding_rule_id,
              short: '-R FORWARDING_RULE_ID',
              long: '--forwarding-rule FORWARDING_RULE_ID',
              description: 'ID of the Network Loadbalancer Forwarding Rule'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Lists all targets of a Network Loadbalancer Forwarding Rule under a data center.'
        @required_options = [
          :datacenter_id, :network_loadbalancer_id, :forwarding_rule_id, :ionoscloud_username, :ionoscloud_password,
        ]
      end

      def run
        $stdout.sync = true
        validate_required_params(@required_options, config)

        $stdout.sync = true
        target_list = [
          ui.color('IP', :bold),
          ui.color('Port', :bold),
          ui.color('Weight', :bold),
          ui.color('Check', :bold),
          ui.color('Check interval', :bold),
          ui.color('Maintenance', :bold),
        ]
        network_loadbalancers_api = Ionoscloud::NetworkLoadBalancersApi.new(api_client)

        network_load_balancer_rule = network_loadbalancers_api.datacenters_networkloadbalancers_forwardingrules_find_by_forwarding_rule_id(
          config[:datacenter_id], config[:network_loadbalancer_id], config[:forwarding_rule_id],
        )

        network_load_balancer_rule.properties.targets.each do |target|
          target_list << target.ip
          target_list << target.port
          target_list << target.weight
          target_list << target.health_check.check
          target_list << target.health_check.check_interval
          target_list << target.health_check.maintenance
        end

        puts ui.list(target_list, :uneven_columns_across, 6)
      end
    end
  end
end
