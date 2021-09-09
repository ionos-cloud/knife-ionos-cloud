require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudLoadbalancerCreate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud loadbalancer create (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'Name of the data center'

      option :name,
              short: '-n NAME',
              long: '--name NAME',
              description: 'Name of the load balancer'

      option :ip,
              long: '--ip IP',
              description: 'IPv4 address of the load balancer. All attached NICs will inherit this IP.'

      option :dhcp,
              short: '-d DHCP',
              long: '--dhcp DHCP',
              description: 'Indicates if the load balancer will reserve an IP using DHCP.'

      option :nics,
              long: '--nics NIC_ID [NIC_ID]',
              description: 'An array of additional private NICs attached to worker nodes'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Creates a load balancer within the VDC. Load balancers can be used for public or private IP traffic.'
        @required_options = [:datacenter_id, :name, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        print "#{ui.color('Creating Load Balancer...', :magenta)}"

        if config[:nics]
          config[:nics] = config[:nics].split(',') if config[:nics].instance_of?(String)
          config[:nics].map! { |nic| { id: nic } }
        end

        load_balancer_api = Ionoscloud::LoadBalancersApi.new(api_client)

        load_balancer, _, headers  = load_balancer_api.datacenters_loadbalancers_post_with_http_info(
          config[:datacenter_id],
          Ionoscloud::Loadbalancer.new(
            properties: Ionoscloud::LoadbalancerProperties.new(
              name: config[:name],
              ip: config[:ip],
              dhcp: config[:dhcp],
            ),
            entities: Ionoscloud::LoadbalancerEntities.new(
              balancednics: Ionoscloud::Nics.new(
                items: config[:nics],
              )
            )
          ),
        )

        dot = ui.color('.', :magenta)
        api_client.wait_for { print dot; is_done? get_request_id headers }

        load_balancer = load_balancer_api.datacenters_loadbalancers_find_by_id(config[:datacenter_id], load_balancer.id, { depth: 1 })

        nics = load_balancer.entities.balancednics.items.map { |nic| nic.id }

        puts "\n"
        puts "#{ui.color('ID', :cyan)}: #{load_balancer.id}"
        puts "#{ui.color('Name', :cyan)}: #{load_balancer.properties.name}"
        puts "#{ui.color('IP address', :cyan)}: #{load_balancer.properties.ip}"
        puts "#{ui.color('DHCP', :cyan)}: #{load_balancer.properties.dhcp}"
        puts "#{ui.color('Balanced Nics', :cyan)}: #{nics.to_s}"
        puts 'done'
      end
    end
  end
end
