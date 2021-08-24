require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudNetworkloadbalancerCreate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud networkloadbalancer create (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'Name of the data center'

      option :name,
              short: '-n NAME',
              long: '--name NAME',
              description: 'Name of the load balancer'

      option :listener_lan,
              short: '-l LISTENER_LAN_ID',
              long: '--listener-lan LISTENER_LAN_ID',
              description: 'Id of the listening LAN. (inbound)'

      option :target_lan,
              short: '-t TARGET_LAN_ID',
              long: '--target-lan TARGET_LAN_ID',
              description: 'Id of the balanced private target LAN. (outbound)'

      option :ips,
              short: '-i IP[,IP,...]',
              long: '--ips IP[,IP,...]',
              description: 'Collection of IP addresses of the Network Load Balancer. (inbound and outbound) '\
                          'IP of the listenerLan must be a customer reserved IP for the public load balancer '\
                          'and private IP for the private load balancer.'

      option :lb_private_ips,
              long: '--private-ips IP[,IP,...]',
              description: 'Collection of private IP addresses with subnet mask of the Network Load Balancer. '\
                          'IPs must contain valid subnet mask. If user will not provide any IP then the system '\
                          'will generate one IP with /24 subnet.'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Creates an Network Load Balancer within the datacenter.'
        @required_options = [:datacenter_id, :name, :listener_lan, :target_lan, :ips, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        print "#{ui.color('Creating Network Load Balancer...', :magenta)}"

        config[:ips] = config[:ips].split(',') if config[:ips] && config[:ips].instance_of?(String)
        config[:lb_private_ips] = config[:lb_private_ips].split(',') if config[:lb_private_ips] && config[:lb_private_ips].instance_of?(String)

        network_load_balancers_api = Ionoscloud::NetworkLoadBalancersApi.new(api_client)

        network_load_balancer, _, headers  = network_load_balancers_api.datacenters_networkloadbalancers_post_with_http_info(
          config[:datacenter_id],
          Ionoscloud::NetworkLoadBalancer.new(
            properties: Ionoscloud::NetworkLoadBalancerProperties.new({
              name: config[:name],
              ips: config[:ips],
              listener_lan: config[:listener_lan],
              target_lan: config[:target_lan],
              lb_private_ips: config[:lb_private_ips],
            }.compact),
          ),
        )


        dot = ui.color('.', :magenta)
        api_client.wait_for { print dot; is_done? get_request_id headers }

        network_load_balancer = network_load_balancers_api.datacenters_networkloadbalancers_find_by_network_load_balancer_id(
          config[:datacenter_id], network_load_balancer.id,
        )

        puts "\n"
        puts "#{ui.color('ID', :cyan)}: #{network_load_balancer.id}"
        puts "#{ui.color('Name', :cyan)}: #{network_load_balancer.properties.name}"
        puts "#{ui.color('Listener LAN', :cyan)}: #{network_load_balancer.properties.listener_lan}"
        puts "#{ui.color('IPS', :cyan)}: #{network_load_balancer.properties.ips}"
        puts "#{ui.color('Target LAN', :cyan)}: #{network_load_balancer.properties.target_lan}"
        puts "#{ui.color('Private IPS', :cyan)}: #{network_load_balancer.properties.lb_private_ips}"
        puts 'done'
      end
    end
  end
end
