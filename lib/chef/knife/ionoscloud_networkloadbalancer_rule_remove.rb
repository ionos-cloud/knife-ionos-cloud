require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudNetworkloadbalancerRuleRemove < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud networkloadbalancer rule remove RULE_ID [RULE_ID] (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'The ID of the data center'

      option :network_loadbalancer_id,
              short: '-L NETWORK_LOADBALANCER_ID',
              long: '--network-loadbalancer NETWORK_LOADBALANCER_ID',
              description: 'ID of the Network Loadbalancer'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Removes the specified rules from a Network Loadbalancer under a data center.'
        @required_options = [:datacenter_id, :network_loadbalancer_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        return unless @name_args.length > 0

        network_loadbalancers_api = Ionoscloud::NetworkLoadBalancersApi.new(api_client)

        headers_to_wait = []
        @name_args.each do |rule_id|
          begin
            _, _, headers = network_loadbalancers_api.datacenters_networkloadbalancers_forwardingrules_delete_with_http_info(
              config[:datacenter_id], config[:network_loadbalancer_id], rule_id,
            )
            headers_to_wait << headers

            ui.warn(
              "Removed Forwarding Rule #{rule_id} from the Network Load balancer "\
              "#{config[:network_loadbalancer_id]}. Request ID: #{get_request_id headers}.",
            )
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("Forwarding rule ID #{rule_id} not found. Skipping.")
            next
          end
        end

        dot = ui.color('.', :magenta)
        headers_to_wait.each { |headers| api_client.wait_for { print dot; is_done? get_request_id headers } }

        print_network_load_balancer(
          network_loadbalancers_api.datacenters_networkloadbalancers_find_by_network_load_balancer_id(
            config[:datacenter_id], config[:network_loadbalancer_id], depth: 2,
          ),
        )
      end
    end
  end
end
