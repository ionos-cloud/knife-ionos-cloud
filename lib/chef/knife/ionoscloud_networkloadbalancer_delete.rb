require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudNetworkloadbalancerDelete < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud networkloadbalancer delete LOAD_BALANCER_ID [LOAD_BALANCER_ID] (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'Name of the data center'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Removes the specified Network Load Balancer.'
        @required_options = [:datacenter_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        validate_required_params(@required_options, config)

        network_load_balancers_api = Ionoscloud::NetworkLoadBalancersApi.new(api_client)

        @name_args.each do |network_load_balancer_id|
          begin
            network_load_balancer = network_load_balancers_api.datacenters_networkloadbalancers_find_by_network_load_balancer_id(
              config[:datacenter_id],
              network_load_balancer_id,
              { depth: 1 },
            )
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("Network Load balancer ID #{network_load_balancer_id} not found. Skipping.")
            next
          end

          msg_pair('ID', network_load_balancer.id)
          msg_pair('Name', network_load_balancer.properties.name)
          msg_pair('Listener LAN', network_load_balancer.properties.listener_lan)
          msg_pair('IPS', network_load_balancer.properties.ips)
          msg_pair('Target LAN', network_load_balancer.properties.target_lan)
          msg_pair('Private IPS', network_load_balancer.properties.lb_private_ips)
          msg_pair('Forwarding Rules', network_load_balancer.entities.forwardingrules.items.map do |rule|
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
            end
          )
          msg_pair('Flowlogs', network_load_balancer.entities.flowlogs.items.map { |flowlog| flowlog.id })

          puts "\n"

          begin
            confirm('Do you really want to delete this Network Load balancer')
          rescue SystemExit => exc
            next
          end

          _, _, headers = network_load_balancers_api.datacenters_networkloadbalancers_delete_with_http_info(
            config[:datacenter_id],
            network_load_balancer_id,
          )
          ui.warn("Deleted Network Load balancer #{network_load_balancer.id}. Request ID: #{get_request_id headers}")
        end
      end
    end
  end
end
