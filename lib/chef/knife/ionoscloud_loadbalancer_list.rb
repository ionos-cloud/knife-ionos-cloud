require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudLoadbalancerList < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud loadbalancer list (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'Name of the data center'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Retrieve a list of load balancers within the virtual data center.'
        @required_options = [:datacenter_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        load_balancers_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('IP address', :bold),
          ui.color('DHCP', :bold),
          ui.color('NICs count', :bold),
        ]

        load_balancer_api = Ionoscloud::LoadBalancersApi.new(api_client)

        load_balancer_api.datacenters_loadbalancers_get(config[:datacenter_id], { depth: 2 }).items.each do |load_balancer|
          load_balancers_list << load_balancer.id
          load_balancers_list << load_balancer.properties.name
          load_balancers_list << load_balancer.properties.ip
          load_balancers_list << load_balancer.properties.dhcp.to_s
          load_balancers_list << load_balancer.entities.balancednics.items.length.to_s
        end

        puts ui.list(load_balancers_list, :uneven_columns_across, 5)
      end
    end
  end
end
