require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudNatgatewayUpdate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud natgateway update (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'ID of the data center'

      option :natgateway_id,
              short: '-G NATGATEWAY_ID',
              long: '--natgateway-id NATGATEWAY_ID',
              description: 'ID of the NAT Gateway'

      option :name,
              short: '-n NAME',
              long: '--name NAME',
              description: 'Name of the NAT gateway'

      option :ips,
              short: '-i IP[,IP,...]',
              long: '--ips IP[,IP,...]',
              description: 'Collection of public IP addresses of the NAT gateway. Should be customer reserved IP addresses in that location'

      option :lans,
              long: '--lans LAN[,LAN,...]',
              description: 'Collection of LANs connected to the NAT gateway. IPs must contain valid subnet mask. If user will not provide any IP then system will generate an IP with /24 subnet.'

      def initialize(args = [])
        super(args)
        @description =
        'Updates information about a Ionoscloud NAT Gateway.'
        @directory = 'compute-engine'
        @required_options = [:datacenter_id, :natgateway_id, :ionoscloud_username, :ionoscloud_password]
        @updatable_fields = [:name, :ips, :lans]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        natgateways_api = Ionoscloud::NATGatewaysApi.new(api_client)

        config[:ips] = config[:ips].split(',') if config[:ips] && config[:ips].instance_of?(String)
        config[:lans] = JSON[config[:lans]] if config[:lans] && config[:lans].instance_of?(String)
        config[:lans] = config[:lans].map do
          |lan|
          Ionoscloud::NatGatewayLanProperties.new(
            id: lan['id'],
            gateway_ips: lan['gateway_ips'],
          )
        end if config[:lans]

        if @updatable_fields.map { |el| config[el] }.any?
          print "#{ui.color('Updating NAT Gateway...', :magenta)}"

          _, _, headers  = natgateways_api.datacenters_natgateways_patch_with_http_info(
            config[:datacenter_id],
            config[:natgateway_id],
            Ionoscloud::NatGatewayProperties.new(
              name: config[:name],
              public_ips: config[:ips],
              lans: config[:lans],
            ),
          )

          dot = ui.color('.', :magenta)
          api_client.wait_for { print dot; is_done? get_request_id headers }
        else
          ui.warn("Nothing to update, please set one of the attributes #{@updatable_fields}.")
        end

        print_natgateway(natgateways_api.datacenters_natgateways_find_by_nat_gateway_id(config[:datacenter_id], config[:natgateway_id], depth: 2))
      end
    end
  end
end
