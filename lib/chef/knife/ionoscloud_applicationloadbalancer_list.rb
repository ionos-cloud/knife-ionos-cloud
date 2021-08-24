require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudApplicationloadbalancerList < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud applicationloadbalancer list (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'Name of the data center'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Retrieve a list of Application Load Balancers within the datacenter.'
        @required_options = [:datacenter_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        validate_required_params

        application_load_balancers_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Listener LAN', :bold),
          ui.color('Target LAN', :bold),
          ui.color('Rules', :bold),
          ui.color('IPS', :bold),
          ui.color('Private IPS', :bold),
        ]

        application_load_balancers_api = Ionoscloud::ApplicationLoadBalancersApi.new(api_client)

        application_load_balancers_api.datacenters_applicationloadbalancers_get(config[:datacenter_id], { depth: 2 }).items.each do |application_load_balancer|
          application_load_balancers_list << application_load_balancer.id
          application_load_balancers_list << application_load_balancer.properties.name
          application_load_balancers_list << application_load_balancer.properties.listener_lan
          application_load_balancers_list << application_load_balancer.properties.target_lan
          application_load_balancers_list << application_load_balancer.entities.forwardingrules.items.length
          application_load_balancers_list << application_load_balancer.properties.ips
          application_load_balancers_list << application_load_balancer.properties.lb_private_ips
        end

        puts ui.list(application_load_balancers_list, :uneven_columns_across, 7)
      end
    end
  end
end
