require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudLoadbalancerGet < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud loadbalancer get (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'ID of the data center'

      option :loadbalancer_id,
              short: '-L LOADBALANCER_ID',
              long: '--loadbalancer-id LOADBALANCER_ID',
              description: 'ID of the load balancer'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Retrieves the attributes of a given load balancer. This will also retrieve a list of NICs associated with the load balancer.'
        @required_options = [:datacenter_id, :loadbalancer_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        validate_required_params(@required_options, config)

        load_balancer_api = Ionoscloud::LoadBalancersApi.new(api_client)

        load_balancer = load_balancer_api.datacenters_loadbalancers_find_by_id(
          config[:datacenter_id],
          config[:loadbalancer_id],
          { depth: 1 },
        )

        nics = load_balancer.entities.balancednics.items.map! { |el| el.id }

        puts "#{ui.color('ID', :cyan)}: #{load_balancer.id}"
        puts "#{ui.color('Name', :cyan)}: #{load_balancer.properties.name}"
        puts "#{ui.color('IP address', :cyan)}: #{load_balancer.properties.ip}"
        puts "#{ui.color('DHCP', :cyan)}: #{load_balancer.properties.dhcp}"
        puts "#{ui.color('Balanced Nics', :cyan)}: #{nics.to_s}"
      end
    end
  end
end
