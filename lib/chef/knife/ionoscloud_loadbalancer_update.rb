require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudLoadbalancerUpdate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud loadbalancer update (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'ID of the data center'

      option :loadbalancer_id,
              short: '-L LOADBALANCER_ID',
              long: '--loadbalancer-id LOADBALANCER_ID',
              description: 'ID of the load balancer'

      option :name,
              short: '-n NAME',
              long: '--name NAME',
              description: 'Name of the load balancer'

      option :ip,
              long: '--ip IP',
              description: 'IPv4 address of the load balancer. All attached NICs will inherit this IP.'

      option :dhcp,
              long: '--dhcp DHCP',
              description: 'Indicates if the load balancer will reserve an IP using DHCP.'

      def initialize(args = [])
        super(args)
        @description =
        'Updates information about a Ionoscloud Load Balancer.'
        @directory = 'compute-engine'
        @required_options = [:datacenter_id, :loadbalancer_id]
        @updatable_fields = [:name, :ip, :dhcp]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        load_balancer_api = Ionoscloud::LoadBalancersApi.new(api_client)

        if @updatable_fields.map { |el| config[el] }.any?
          print "#{ui.color('Updating Load Balancer...', :magenta)}"

          _, _, headers  = load_balancer_api.datacenters_loadbalancers_patch_with_http_info(
            config[:datacenter_id],
            config[:loadbalancer_id],
            Ionoscloud::LoadbalancerProperties.new(
              name: config[:name],
              dhcp: (config.key?(:dhcp) ? config[:dhcp].to_s.downcase == 'true' : nil),
              ip: config[:ip],
            ),
          )

          dot = ui.color('.', :magenta)
          api_client.wait_for { print dot; is_done? get_request_id headers }
        else
          ui.warn("Nothing to update, please set one of the attributes #{@updatable_fields}.")
        end

        print_load_balancer(load_balancer_api.datacenters_loadbalancers_find_by_id(config[:datacenter_id], config[:loadbalancer_id]))
      end
    end
  end
end
