require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudApplicationloadbalancerCreate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud applicationloadbalancer create (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'ID of the data center'

      option :name,
              short: '-n NAME',
              long: '--name NAME',
              description: 'Name of the Application Load Balancer'

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
              description: 'Collection of IP addresses of the Application Load Balancer. (inbound and outbound) IP of the '\
              'listenerLan must be a customer reserved IP for the public load balancer and private IP for the private load balancer.'

      option :lb_private_ips,
              long: '--private-ips IP[,IP,...]',
              description: 'Collection of private IP addresses with subnet mask of the Application Load Balancer. '\
              'IPs must contain valid subnet mask. If user will not provide any IP then the system will generate one IP with /24 subnet.'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Creates an Application Load Balancer within the datacenter.'
        @directory = 'application-loadbalancer'
        @required_options = [:datacenter_id, :name, :listener_lan, :target_lan, :ips]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        print "#{ui.color('Creating Application Load Balancer...', :magenta)}"

        config[:ips] = config[:ips].split(',') if config[:ips] && config[:ips].instance_of?(String)
        config[:lb_private_ips] = config[:lb_private_ips].split(',') if config[:lb_private_ips] && config[:lb_private_ips].instance_of?(String)

        application_load_balancers_api = Ionoscloud::ApplicationLoadBalancersApi.new(api_client)

        application_load_balancer, _, headers  = application_load_balancers_api.datacenters_applicationloadbalancers_post_with_http_info(
          config[:datacenter_id],
          Ionoscloud::ApplicationLoadBalancer.new(
            properties: Ionoscloud::ApplicationLoadBalancerProperties.new({
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

        print_application_loadbalancer(application_load_balancers_api.datacenters_applicationloadbalancers_find_by_application_load_balancer_id(
                                         config[:datacenter_id], application_load_balancer.id, depth: 2,
        ))
      end
    end
  end
end
