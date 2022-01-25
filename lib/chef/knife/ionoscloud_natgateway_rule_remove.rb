require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudNatgatewayRuleRemove < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud natgateway rule remove RULE_ID [RULE_ID] (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'Name of the data center'

      option :natgateway_id,
              short: '-G NATGATEWAY_ID',
              long: '--natgateway-id NATGATEWAY_ID',
              description: 'ID of the NAT Gateway'

      def initialize(args = [])
        super(args)
        @description =
        'Removes the specified rules from a Nat Gateway under a data center.'
        @directory = 'compute-engine'
        @required_options = [:datacenter_id, :natgateway_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        return unless @name_args.length > 0

        natgateways_api = Ionoscloud::NATGatewaysApi.new(api_client)

        headers_to_wait = []
        @name_args.each do |rule_id|
          _, _, headers = natgateways_api.datacenters_natgateways_rules_delete_with_http_info(config[:datacenter_id], config[:natgateway_id], rule_id)
          headers_to_wait << headers
        end

        print "#{ui.color("Removing rules #{@name_args} from the NAT Gateway...", :magenta)}"
        dot = ui.color('.', :magenta)

        headers_to_wait.each { |headers| api_client.wait_for { print dot; is_done? get_request_id headers } }

        print_natgateway(
          natgateways_api.datacenters_natgateways_find_by_nat_gateway_id(config[:datacenter_id], config[:natgateway_id], depth: 2),
        )
      end
    end
  end
end
