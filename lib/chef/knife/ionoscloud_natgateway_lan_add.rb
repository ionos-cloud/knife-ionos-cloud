require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudNatgatewayLanAdd < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud natgateway lan add (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'Name of the data center'

      option :natgateway_id,
              short: '-G NATGATEWAY_ID',
              long: '--natgateway-id NATGATEWAY_ID',
              description: 'ID of the NAT Gateway'

      option :lan_id,
              short: '-L LAN_ID',
              long: '--lan LAN_ID',
              description: 'ID of the LAN'

      option :gateway_ips,
              short: '-i IP[,IP,...]',
              long: '--ips IP[,IP,...]',
              description: 'Collection of gateway IP addresses of the NAT gateway. '\
                          'Will be auto-generated if not provided. Should ideally be an IP belonging to the same subnet as the LAN'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Adds a LAN to a Nat Gateway under a data center.'
        @required_options = [:datacenter_id, :natgateway_id, :lan_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        validate_required_params

        natgateways_api = Ionoscloud::NATGatewaysApi.new(api_client)

        if config[:gateway_ips]
          config[:gateway_ips] = config[:gateway_ips].split(',')
        end

        natgateway = natgateways_api.datacenters_natgateways_find_by_nat_gateway_id(config[:datacenter_id], config[:natgateway_id])

        existing_lan = natgateway.properties.lans.find { |lan| lan.id == Integer(config[:lan_id]) }

        if existing_lan
          existing_lan.gateway_ips = config[:gateway_ips]
        else
          natgateway.properties.lans.append(
            Ionoscloud::NatGatewayLanProperties.new(
              id: Integer(config[:lan_id]),
              gateway_ips: config[:gateway_ips],
            ),
          )
        end

        _, _, headers = natgateways_api.datacenters_natgateways_patch_with_http_info(config[:datacenter_id], config[:natgateway_id], natgateway.properties)

        print "#{ui.color('Adding the LAN to the Nat Gateway...', :magenta)}"
        dot = ui.color('.', :magenta)
        api_client.wait_for { print dot; is_done? get_request_id headers }

        natgateway = natgateways_api.datacenters_natgateways_find_by_nat_gateway_id(config[:datacenter_id], config[:natgateway_id])

        puts "\n"
        puts "#{ui.color('ID', :cyan)}: #{natgateway.id}"
        puts "#{ui.color('Name', :cyan)}: #{natgateway.properties.name}"
        puts "#{ui.color('IPS', :cyan)}: #{natgateway.properties.public_ips}"
        puts "#{ui.color('LANS', :cyan)}: #{natgateway.properties.lans.map { |el| { id: el.id, gateway_ips: el.gateway_ips } }}"
        puts 'done'
      end
    end
  end
end
