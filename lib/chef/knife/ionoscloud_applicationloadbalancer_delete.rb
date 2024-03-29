require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudApplicationloadbalancerDelete < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud applicationloadbalancer delete LOAD_BALANCER_ID [LOAD_BALANCER_ID] (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'Name of the data center'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Removes the specified Application Load Balancer.'
        @directory = 'application-loadbalancer'
        @required_options = [:datacenter_id]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        application_load_balancers_api = Ionoscloud::ApplicationLoadBalancersApi.new(api_client)

        @name_args.each do |application_load_balancer_id|
          begin
            application_load_balancer = application_load_balancers_api.datacenters_applicationloadbalancers_find_by_application_load_balancer_id(
              config[:datacenter_id],
              application_load_balancer_id,
              { depth: 2 },
            )
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("Application Load balancer ID #{application_load_balancer_id} not found. Skipping.")
            next
          end

          print_application_loadbalancer(application_load_balancer)

          puts "\n"

          begin
            confirm('Do you really want to delete this Application Load balancer')
          rescue SystemExit
            next
          end

          _, _, headers = application_load_balancers_api.datacenters_applicationloadbalancers_delete_with_http_info(
            config[:datacenter_id],
            application_load_balancer_id,
          )
          ui.warn("Deleted Application Load balancer #{application_load_balancer.id}. Request ID: #{get_request_id headers}")
        end
      end
    end
  end
end
