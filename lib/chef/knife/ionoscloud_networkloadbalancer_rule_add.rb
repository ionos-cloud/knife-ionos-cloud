require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudNetworkloadbalancerRuleAdd < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud networkloadbalancer rule add (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'Name of the data center'

      option :network_loadbalancer_id,
              short: '-L NETWORK_LOADBALANCER_ID',
              long: '--network-loadbalancer NETWORK_LOADBALANCER_ID',
              description: 'ID of the Network Loadbalancer'

      option :name,
              short: '-n NAME',
              long: '--name NAME',
              description: 'A name of that Network Load Balancer forwarding rule'

      option :algorithm,
              short: '-a ALGORITHM',
              long: '--algorithm ALGORITHM',
              description: 'Algorithm for the balancing'

      option :protocol,
              long: '--protocol PROTOCOL',
              description: 'Protocol of the balancing'

      option :listener_ip,
              short: '-i LISTENER_IP',
              long: '--ip LISTENER_IP',
              description: 'Listening IP. (inbound)'

      option :listener_port,
              short: '-p LISTENER_PORT',
              long: '--port LISTENER_PORT',
              description: 'Listening port number. (inbound) (range: 1 to 65535)'

      option :client_timeout,
              long: '--client-timeout CLIENT_TIMEOUT',
              description: 'ClientTimeout is expressed in milliseconds. This inactivity timeout applies when '\
              'the client is expected to acknowledge or send data. If unset the default of 50 seconds will be used.'

      option :connect_timeout,
              long: '--connect-timeout CONNECT_TIMEOUT',
              description: 'It specifies the maximum time (in milliseconds) to wait for a connection attempt to a '\
              'target VM to succeed. If unset, the default of 5 seconds will be used.'

      option :target_timeout,
              long: '--terget-timeout TARGET_TIMEOUT',
              description: 'TargetTimeout specifies the maximum inactivity time (in milliseconds) on the target VM side. '\
              'If unset, the default of 50 seconds will be used.'

      option :retries,
              short: '-r RETRIES',
              long: '--retries RETRIES',
              description: 'Retries specifies the number of retries to perform on a target VM after a connection failure. '\
              'If unset, the default value of 3 will be used. (valid range: [0, 65535])'

      option :targets,
              long: '--targets TARGETS',
              description: 'Array of targets'

      def initialize(args = [])
        super(args)
        @description =
        'Adds a Forwarding Rule to a Network Load Balancer under a data center.'
        @directory = 'compute-engine'
        @required_options = [:datacenter_id, :network_loadbalancer_id, :name, :listener_ip, :listener_port, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        network_loadbalancers_api = Ionoscloud::NetworkLoadBalancersApi.new(api_client)

        config[:gateway_ips] = config[:gateway_ips].split(',') if config[:gateway_ips] && config[:gateway_ips].instance_of?(String)
        config[:targets] = JSON[config[:targets]] if config[:targets] && config[:targets].instance_of?(String)

        config[:targets] = config[:targets].map do |condition|
          Ionoscloud::NetworkLoadBalancerForwardingRuleTarget.new(
            ip: condition['ip'],
            port: condition['port'],
            weight: condition['weight'],
            health_check: Ionoscloud::NetworkLoadBalancerForwardingRuleTargetHealthCheck.new(
              check: condition['check'],
              check_interval: condition['check_interval'],
              maintenance: condition['maintenance'],
            ),
          )
        end if config[:targets]

        network_loadbalancer_forwarding_rule = Ionoscloud::NetworkLoadBalancerForwardingRule.new(
          properties: Ionoscloud::NetworkLoadBalancerForwardingRuleProperties.new(
            name: config[:name],
            algorithm: config[:algorithm],
            protocol: config[:protocol],
            listener_ip: config[:listener_ip],
            listener_port: config[:listener_port],
            targets: config[:targets],
            health_check: Ionoscloud::NetworkLoadBalancerForwardingRuleHealthCheck.new(
              client_timeout: config[:client_timeout],
              connect_timeout: config[:connect_timeout],
              target_timeout: config[:target_timeout],
              retries: config[:retries],
            ),
          ),
        )

        _, _, headers = network_loadbalancers_api.datacenters_networkloadbalancers_forwardingrules_post_with_http_info(
          config[:datacenter_id], config[:network_loadbalancer_id], network_loadbalancer_forwarding_rule,
        )

        print "#{ui.color('Adding the rule to the Network Loadbalancer...', :magenta)}"
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
