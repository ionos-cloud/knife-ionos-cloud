require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudNetworkloadbalancerRuleRemove < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud networkloadbalancer rule remove RULE_ID [RULE_ID] (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'The ID of the data center'

      option :network_loadbalancer_id,
              short: '-L NETWORK_LOADBALANCER_ID',
              long: '--network-loadbalancer NETWORK_LOADBALANCER_ID',
              description: 'ID of the Network Loadbalancer'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Removes the specified rules from a Network Loadbalancer under a data center.'
        @required_options = [:datacenter_id, :network_loadbalancer_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        validate_required_params(@required_options, config)

        return unless @name_args.length > 0

        network_loadbalancers_api = Ionoscloud::NetworkLoadBalancersApi.new(api_client)

        headers_to_wait = []
        @name_args.each do |rule_id|
          _, _, headers = network_loadbalancers_api.datacenters_networkloadbalancers_forwardingrules_delete_with_http_info(
            config[:datacenter_id], config[:network_loadbalancer_id], rule_id,
          )
          headers_to_wait << headers
        end

        print "#{ui.color("Removing rules #{@name_args} from the Network Loadbalancer...", :magenta)}"
        dot = ui.color('.', :magenta)

        headers_to_wait.each { |headers| api_client.wait_for { print dot; is_done? get_request_id headers } }

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
