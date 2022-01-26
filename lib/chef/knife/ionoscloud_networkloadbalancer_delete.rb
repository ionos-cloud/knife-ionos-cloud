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

      def initialize(args = [])
        super(args)
        @description =
        'Removes the specified Network Load Balancer.'
        @directory = 'compute-engine'
        @required_options = [:datacenter_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        network_load_balancers_api = Ionoscloud::NetworkLoadBalancersApi.new(api_client)

        @name_args.each do |network_load_balancer_id|
          begin
            network_load_balancer = network_load_balancers_api.datacenters_networkloadbalancers_find_by_network_load_balancer_id(
              config[:datacenter_id],
              network_load_balancer_id,
              depth: 2,
            )
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("Network Load balancer ID #{network_load_balancer_id} not found. Skipping.")
            next
          end

          print_network_load_balancer(network_load_balancer)
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
