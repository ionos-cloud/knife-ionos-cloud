require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudLoadbalancerDelete < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud loadbalancer delete LOAD_BALANCER_ID [LOAD_BALANCER_ID] (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'Name of the data center'

      def initialize(args = [])
        super(args)
        @description =
        'Deletes the specified load balancer.'
        @directory = 'compute-engine'
        @required_options = [:datacenter_id]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        load_balancer_api = Ionoscloud::LoadBalancersApi.new(api_client)

        @name_args.each do |load_balancer_id|
          begin
            load_balancer = load_balancer_api.datacenters_loadbalancers_find_by_id(
              config[:datacenter_id],
              load_balancer_id,
              { depth: 1 },
            )
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("Load balancer ID #{load_balancer_id} not found. Skipping.")
            next
          end

          print_load_balancer(load_balancer)
          puts "\n"

          begin
            confirm('Do you really want to delete this Load balancer')
          rescue SystemExit
            next
          end

          _, _, headers = load_balancer_api.datacenters_loadbalancers_delete_with_http_info(
            config[:datacenter_id],
            load_balancer_id,
          )
          ui.warn("Deleted Load balancer #{load_balancer.id}. Request ID: #{get_request_id headers}")
        end
      end
    end
  end
end
