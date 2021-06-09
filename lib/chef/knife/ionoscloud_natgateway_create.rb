require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudNatgatewayCreate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud natgateway create (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'Name of the data center'

      option :name,
              short: '-n NAME',
              long: '--name NAME',
              description: 'Name of the server'

      option :ips,
              short: '-i IP[,IP,...]',
              long: '--ips IP[,IP,...]',
              description: 'IPs assigned to the NIC'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Creates a new Nat Gateway under a data center.'
        @required_options = [:datacenter_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        validate_required_params(@required_options, config)

        natgateways_api = Ionoscloud::NATGatewaysApi.new(api_client)

        if config[:ips]
          config[:ips] = config[:ips].split(',')
        end

        natgateway = Ionoscloud::NatGateway.new(
          properties: Ionoscloud::NatGatewayProperties.new(
            name: config[:name],
            public_ips: config[:ips],
          )
        )

        natgateway, _, headers = natgateways_api.datacenters_natgateways_post_with_http_info(
          config[:datacenter_id],
          natgateway,
        )

        print "#{ui.color('Creating Nat Gateway...', :magenta)}"
        dot = ui.color('.', :magenta)
        api_client.wait_for { print dot; is_done? get_request_id headers }

        natgateway = natgateways_api.datacenters_natgateways_find_by_nat_gateway_id(config[:datacenter_id], natgateway.id)

        puts "\n"
        puts "#{ui.color('ID', :cyan)}: #{natgateway.id}"
        puts "#{ui.color('Name', :cyan)}: #{natgateway.properties.name}"
        puts "#{ui.color('IPS', :cyan)}: #{natgateway.properties.public_ips}"

        puts 'done'
      end
    end
  end
end
