require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudNetworkloadbalancerRuleTargetAdd < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud networkloadbalancer rule target add (options)'

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

      option :weight,
              short: '-w WEIGTH',
              long: '--weight WEIGTH',
              description: 'Weight parameter is used to adjust the target VM\'s weight relative to other target VMs. '\
              'All target VMs will receive a load proportional to their weight relative to the sum of all weights, so '\
              'the higher the weight, the higher the load. The default weight is 1, and the maximal value is 256. A '\
              'value of 0 means the target VM will not participate in load-balancing but will still accept persistent '\
              'connections. If this parameter is used to distribute the load according to target VM\'s capacity, it is '\
              'recommended to start with values which can both grow and shrink, for instance between 10 and 100 to leave '\
              'enough room above and below for later adjustments.'

      option :check,
              short: '-c',
              long: '--check',
              description: 'Check specifies whether the target VM\'s health is checked. If turned off, a target VM is '\
              'always considered available. If turned on, the target VM is available when accepting periodic TCP connections, '\
              'to ensure that it is really able to serve requests. The address and port to send the tests to are those of the '\
              'target VM. The health check only consists of a connection attempt.',
              boolean: true

      option :check_interval,
              long: '--check-interval CHECK_INTERVAL',
              description: 'CheckInterval determines the duration (in milliseconds) between consecutive health checks. '\
              'If unspecified a default of 2000 ms is used.'

      option :maintenance,
              short: '-m',
              long: '--maintenance MAINTENANCE',
              description: 'Maintenance specifies if a target VM should be marked as down, even if it is not.',
              boolean: true

      def initialize(args = [])
        super(args)
        @description =
        'Adds a target to a Network Load Balancer Forwarding Rule under a data center.'
        @directory = 'compute-engine'
        @required_options = [
          :datacenter_id, :network_loadbalancer_id, :forwarding_rule_id, :ip, :port, :weight, :ionoscloud_username, :ionoscloud_password,
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

        network_loadbalancer_forwarding_rule_target = Ionoscloud::NetworkLoadBalancerForwardingRuleTarget.new(
          ip: config[:ip],
          port: config[:port],
          weight: config[:weight],
          health_check: Ionoscloud::NetworkLoadBalancerForwardingRuleTargetHealthCheck.new(
            check: config[:check],
            check_interval: config[:check_interval],
            maintenance: config[:maintenance],
          ),
        )

        network_load_balancer_rule.properties.targets << network_loadbalancer_forwarding_rule_target

        _, _, headers  = network_loadbalancers_api.datacenters_networkloadbalancers_forwardingrules_patch_with_http_info(
          config[:datacenter_id],
          config[:network_loadbalancer_id],
          config[:forwarding_rule_id],
          Ionoscloud::NetworkLoadBalancerForwardingRuleProperties.new({
            targets: network_load_balancer_rule.properties.targets,
          }),
        )

        print "#{ui.color('Adding the target to the Network Loadbalancer Forwarding Rule...', :magenta)}"
        dot = ui.color('.', :magenta)
        api_client.wait_for { print dot; is_done? get_request_id headers }

        print_network_load_balancer(
          network_loadbalancers_api.datacenters_networkloadbalancers_find_by_network_load_balancer_id(
            config[:datacenter_id], config[:network_loadbalancer_id], depth: 2,
          ),
        )
      end
    end
  end
end
