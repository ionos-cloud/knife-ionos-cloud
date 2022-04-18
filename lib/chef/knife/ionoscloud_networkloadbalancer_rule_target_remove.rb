require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudNetworkloadbalancerRuleTargetRemove < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud networkloadbalancer rule target remove (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'Name of the data center'

      option :network_loadbalancer_id,
              short: '-L NETWORK_LOADBALANCER_ID',
              long: '--network-loadbalancer NETWORK_LOADBALANCER_ID',
              description: 'ID of the Network Loadbalancer'

      option :forwarding_rule_id,
              short: '-R FORWARDING_RULE_ID',
              long: '--forwarding-rule FORWARDING_RULE_ID',
              description: 'ID of the Network Loadbalancer Forwarding Rule'

      option :ip,
              short: '-i IP',
              long: '--ip IP',
              description: 'IP of a balanced target VM'

      option :port,
              short: '-p PORT',
              long: '--port PORT',
              description: 'Port of the balanced target service. (range: 1 to 65535)'

      def initialize(args = [])
        super(args)
        @description =
        'Adds a target to a Network Load Balancer Forwarding Rule under a data center.'
        @directory = 'compute-engine'
        @required_options = [
          :datacenter_id, :network_loadbalancer_id, :forwarding_rule_id, :ip, :port, :ionoscloud_username, :ionoscloud_password,
        ]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        network_loadbalancers_api = Ionoscloud::NetworkLoadBalancersApi.new(api_client)


        network_load_balancer_rule = network_loadbalancers_api.datacenters_networkloadbalancers_forwardingrules_find_by_forwarding_rule_id(
          config[:datacenter_id], config[:network_loadbalancer_id], config[:forwarding_rule_id],
        )

        initial_length = network_load_balancer_rule.properties.targets.length

        network_load_balancer_rule.properties.targets = network_load_balancer_rule.properties.targets.reject do |target|
          target.ip == config[:ip] && target.port == Integer(config[:port])
        end

        if initial_length > network_load_balancer_rule.properties.targets.length
          _, _, headers  = network_loadbalancers_api.datacenters_networkloadbalancers_forwardingrules_patch_with_http_info(
            config[:datacenter_id],
            config[:network_loadbalancer_id],
            config[:forwarding_rule_id],
            Ionoscloud::NetworkLoadBalancerForwardingRuleProperties.new({
              targets: network_load_balancer_rule.properties.targets,
            }),
          )

          print "#{ui.color('Removing the target from the Network Loadbalancer Forwarding Rule...', :magenta)}"
          dot = ui.color('.', :magenta)
          api_client.wait_for { print dot; is_done? get_request_id headers }
        end

        print_network_load_balancer(
          network_loadbalancers_api.datacenters_networkloadbalancers_find_by_network_load_balancer_id(
            config[:datacenter_id], config[:network_loadbalancer_id], depth: 2,
          ),
        )
      end
    end
  end
end
