require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudNatgatewayGet < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud natgateway get (options)'

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
        'Retrieves the attributes of a given NAT Gateway.'
        @directory = 'compute-engine'
        @required_options = [:datacenter_id, :natgateway_id]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        natgateways_api = Ionoscloud::NATGatewaysApi.new(api_client)

        print_natgateway(
          natgateways_api.datacenters_natgateways_find_by_nat_gateway_id(config[:datacenter_id], config[:natgateway_id], depth: 2),
        )
      end
    end
  end
end
