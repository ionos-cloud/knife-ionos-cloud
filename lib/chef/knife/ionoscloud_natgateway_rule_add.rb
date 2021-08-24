require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudNatgatewayRuleAdd < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud natgateway rule add (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'Name of the data center'

      option :natgateway_id,
              short: '-G NATGATEWAY_ID',
              long: '--natgateway-id NATGATEWAY_ID',
              description: 'ID of the NAT Gateway'

      option :name,
              short: '-n NAME',
              long: '--name NAME',
              description: 'Name of the NAT gateway rule'

      option :type,
              short: '-t TYPE',
              long: '--type TYPE',
              description: 'Type of the NAT gateway rule',
              default: 'SNAT'

      option :protocol,
              short: '-p PROTOCOL',
              long: '--protocol PROTOCOL',
              description: "Protocol of the NAT gateway rule. Defaults to ALL. If protocol is "\
              "'ICMP' then target_port_range start and end cannot be set.",
              default: 'ALL'

      option :source_subnet,
              long: '--source SOURCE_SUBNET',
              description: 'Source subnet of the NAT gateway rule. For SNAT rules it specifies '\
              'which packets this translation rule applies to based on the packets source IP address.'

      option :public_ip,
              short: '-i PUBLIC_IP',
              long: '--ip PUBLIC_IP',
              description: 'Public IP address of the NAT gateway rule. Specifies the address used for masking outgoing '\
              'packets source address field. Should be one of the customer reserved IP address already configured on the NAT gateway resource'

      option :target_subnet,
              long: '--target TARGET_SUBNET',
              description: 'Target or destination subnet of the NAT gateway rule. For SNAT rules it specifies which packets '\
              'this translation rule applies to based on the packets destination IP address. If none is provided, rule will match any address'

      option :target_port_range_start,
              long: '--port-start PORT_RANGE_START',
              description: 'Target port range start associated with the NAT gateway rule'

      option :target_port_range_end,
              long: '--port-end PORT_RANGE_START',
              description: 'Target port range end associated with the NAT gateway rule'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Adds a LAN to a Nat Gateway under a data center.'
        @required_options = [:datacenter_id, :natgateway_id, :name, :source_subnet, :public_ip, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        validate_required_params

        natgateways_api = Ionoscloud::NATGatewaysApi.new(api_client)

        natgateway_rule = Ionoscloud::NatGatewayRule.new(
          properties: Ionoscloud::NatGatewayRuleProperties.new(
            name: config[:name],
            type: config[:type],
            protocol: config[:protocol],
            public_ip: config[:public_ip],
            source_subnet: config[:source_subnet],
            target_subnet: config[:target_subnet],
            target_port_range: Ionoscloud::TargetPortRange.new(
              start: config[:target_port_range_start],
              _end: config[:target_port_range_end],
            ),
          ),
        )

        _, _, headers = natgateways_api.datacenters_natgateways_rules_post_with_http_info(
          config[:datacenter_id], config[:natgateway_id], natgateway_rule,
        )

        print "#{ui.color('Adding the rule to the Nat Gateway...', :magenta)}"
        dot = ui.color('.', :magenta)
        api_client.wait_for { print dot; is_done? get_request_id headers }

        natgateway = natgateways_api.datacenters_natgateways_find_by_nat_gateway_id(config[:datacenter_id], config[:natgateway_id], depth: 2)

        puts "\n"
        puts "#{ui.color('ID', :cyan)}: #{natgateway.id}"
        puts "#{ui.color('Name', :cyan)}: #{natgateway.properties.name}"
        puts "#{ui.color('IPS', :cyan)}: #{natgateway.properties.public_ips}"
        puts "#{ui.color('LANS', :cyan)}: #{natgateway.properties.lans.map { |el| { id: el.id, gateway_ips: el.gateway_ips } }}"
        puts "#{ui.color('Rules', :cyan)}: #{natgateway.entities.rules.items.map do |el|
          {
            id: el.id,
            name: el.properties.name,
            type: el.properties.type,
            protocol: el.properties.protocol,
            public_ip: el.properties.public_ip,
            source_subnet: el.properties.source_subnet,
            target_subnet: el.properties.target_subnet,
            target_port_range_start: el.properties.target_port_range ? el.properties.target_port_range.start : '',
            target_port_range_end: el.properties.target_port_range ? el.properties.target_port_range._end : '',
          }
        end}"
        puts 'done'
      end
    end
  end
end
