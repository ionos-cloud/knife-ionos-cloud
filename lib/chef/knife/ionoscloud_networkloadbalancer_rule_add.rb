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
              description: 'Algorithm for the balancing',
              default: 'ROUND_ROBIN'

      option :protocol,
              long: '--protocol PROTOCOL',
              description: 'Protocol of the balancing',
              default: 'TCP'

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
              'the client is expected to acknowledge or send data. If unset the default of 50 seconds will be used.',
              default: 50

      option :connect_timeout,
              long: '--connect-timeout CONNECT_TIMEOUT',
              description: 'It specifies the maximum time (in milliseconds) to wait for a connection attempt to a '\
              'target VM to succeed. If unset, the default of 5 seconds will be used.',
              default: 5000

      option :target_timeout,
              long: '--terget-timeout TARGET_TIMEOUT',
              description: 'TargetTimeout specifies the maximum inactivity time (in milliseconds) on the target VM side. '\
              'If unset, the default of 50 seconds will be used.',
              default: 50000

      option :retries,
              short: '-r RETRIES',
              long: '--retries RETRIES',
              description: 'Retries specifies the number of retries to perform on a target VM after a connection failure. '\
              'If unset, the default value of 3 will be used. (valid range: [0, 65535])',
              default: 3

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Adds a Forwarding Rule to a Network Load Balancer under a data center.'
        @required_options = [:datacenter_id, :network_loadbalancer_id, :name, :listener_ip, :listener_port, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        validate_required_params(@required_options, config)

        network_loadbalancers_api = Ionoscloud::NetworkLoadBalancersApi.new(api_client)

        if config[:gateway_ips]
          config[:gateway_ips] = config[:gateway_ips].split(',')
        end

        network_loadbalancer_forwarding_rule = Ionoscloud::NetworkLoadBalancerForwardingRule.new(
          properties: Ionoscloud::NetworkLoadBalancerForwardingRuleProperties.new(
            name: config[:name],
            algorithm: config[:algorithm],
            protocol: config[:protocol],
            listener_ip: config[:listener_ip],
            listener_port: config[:listener_port],
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

        network_load_balancer = network_loadbalancers_api.datacenters_networkloadbalancers_find_by_network_load_balancer_id(
          config[:datacenter_id], config[:network_loadbalancer_id], depth: 2,
        )

        puts "\n"
        puts "#{ui.color('ID', :cyan)}: #{network_load_balancer.id}"
        puts "#{ui.color('Name', :cyan)}: #{network_load_balancer.properties.name}"
        puts "#{ui.color('Listener LAN', :cyan)}: #{network_load_balancer.properties.listener_lan}"
        puts "#{ui.color('IPS', :cyan)}: #{network_load_balancer.properties.ips}"
        puts "#{ui.color('Target LAN', :cyan)}: #{network_load_balancer.properties.target_lan}"
        puts "#{ui.color('Private IPS', :cyan)}: #{network_load_balancer.properties.lb_private_ips}"
        puts "#{ui.color('Forwarding Rules', :cyan)}: #{network_load_balancer.entities.forwardingrules.items.map do |rule|
          {
            id: rule.id,
            name: rule.properties.name,
            algorithm: rule.properties.algorithm,
            protocol: rule.properties.protocol,
            listener_ip: rule.properties.listener_ip,
            listener_port: rule.properties.listener_port,
            health_check: rule.properties.health_check,
            targets: rule.properties.targets,
          }
        end}"
        puts "#{ui.color('Flowlogs', :cyan)}: #{network_load_balancer.entities.flowlogs.items.map { |flowlog| flowlog.id }}"
        puts 'done'
      end
    end
  end
end
