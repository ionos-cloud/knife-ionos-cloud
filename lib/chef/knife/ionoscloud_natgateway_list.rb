require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudNatgatewayList < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud natgateway list (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'The ID of the data center'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Lists all available NAT Gateways under a data center.'
        @required_options = [:datacenter_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        $stdout.sync = true
        natgateway_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('IPS', :bold),
          ui.color('LANS', :bold),
          ui.color('Rules Count', :bold),
        ]
        natgateways_api = Ionoscloud::NATGatewaysApi.new(api_client)

        natgateways_api.datacenters_natgateways_get(config[:datacenter_id], { depth: 3 }).items.each do |natgateway|
          natgateway_list << natgateway.id
          natgateway_list << natgateway.properties.name
          natgateway_list << natgateway.properties.public_ips
          natgateway_list << natgateway.properties.lans.map { |el| { id: el.id, gateway_ips: el.gateway_ips } }
          natgateway_list << natgateway.entities.rules.items.length
        end
        puts ui.list(natgateway_list, :uneven_columns_across, 5)
      end
    end
  end
end
