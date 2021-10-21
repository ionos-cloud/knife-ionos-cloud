require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudNatgatewayRuleList < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud natgateway rule list (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'The ID of the data center'

      option :natgateway_id,
              short: '-G NATGATEWAY_ID',
              long: '--natgateway-id NATGATEWAY_ID',
              description: 'ID of the NAT Gateway'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Lists all available rules in a NAT Gateways under a data center.'
        @required_options = [:datacenter_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        $stdout.sync = true
        handle_extra_config
        natgateway_rules_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Type', :bold),
          ui.color('Protocol', :bold),
          ui.color('Public IP', :bold),
          ui.color('Source Subnet', :bold),
          ui.color('Target Subnet', :bold),
          ui.color('Target Port Range Start', :bold),
          ui.color('Target Port Range End', :bold),
        ]
        natgateways_api = Ionoscloud::NATGatewaysApi.new(api_client)

        natgateways_api.datacenters_natgateways_rules_get(config[:datacenter_id], config[:natgateway_id], { depth: 1 }).items.each do |natgateway_rule|
          natgateway_rules_list << natgateway_rule.id
          natgateway_rules_list << natgateway_rule.properties.name
          natgateway_rules_list << natgateway_rule.properties.type
          natgateway_rules_list << natgateway_rule.properties.protocol
          natgateway_rules_list << natgateway_rule.properties.public_ip
          natgateway_rules_list << natgateway_rule.properties.source_subnet
          natgateway_rules_list << natgateway_rule.properties.target_subnet
          natgateway_rules_list << (natgateway_rule.properties.target_port_range ? natgateway_rule.properties.target_port_range.start : '')
          natgateway_rules_list << (natgateway_rule.properties.target_port_range ? natgateway_rule.properties.target_port_range._end : '')
        end

        puts ui.list(natgateway_rules_list, :uneven_columns_across, 9)
      end
    end
  end
end
