require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudNetworkloadbalancerUpdate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud networkloadbalancer update (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'ID of the data center'

      option :network_loadbalancer_id,
              short: '-L NETWORK_LOADBALANCER_ID',
              long: '--network-loadbalancer NETWORK_LOADBALANCER_ID',
              description: 'ID of the Network Loadbalancer'

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


      def initialize(args = [])
        super(args)
        @description =
        'Updates information about a Ionoscloud Network Load Balancer.'
        @directory = 'compute-engine'
        @required_options = [:datacenter_id, :network_loadbalancer_id]
        @updatable_fields = [:name, :listener_lan, :target_lan, :ips, :lb_private_ips]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        config[:ips] = config[:ips].split(',') if config[:ips] && config[:ips].instance_of?(String)
        config[:lb_private_ips] = config[:lb_private_ips].split(',') if config[:lb_private_ips] && config[:lb_private_ips].instance_of?(String)

        network_load_balancer_api = Ionoscloud::NetworkLoadBalancersApi.new(api_client)

        if @updatable_fields.map { |el| config[el] }.any?
          print "#{ui.color('Updating Network Load Balancer...', :magenta)}"

          _, _, headers  = network_load_balancer_api.datacenters_networkloadbalancers_patch_with_http_info(
            config[:datacenter_id],
            config[:network_loadbalancer_id],
            Ionoscloud::NetworkLoadBalancerProperties.new({
              name: config[:name],
              ips: config[:ips],
              listener_lan: config[:listener_lan],
              target_lan: config[:target_lan],
              lb_private_ips: config[:lb_private_ips],
            }.compact),
          )

          dot = ui.color('.', :magenta)
          api_client.wait_for { print dot; is_done? get_request_id headers }
        else
          ui.warn("Nothing to update, please set one of the attributes #{@updatable_fields}.")
        end

        print_network_load_balancer(
          network_load_balancer_api.datacenters_networkloadbalancers_find_by_network_load_balancer_id(
            config[:datacenter_id], config[:network_loadbalancer_id], depth: 2,
          ),
        )
      end
    end
  end
end
