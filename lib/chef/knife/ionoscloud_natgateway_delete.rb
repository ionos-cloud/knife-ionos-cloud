require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudNatgatewayDelete < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud natgateway delete NATGATEWAY_ID [NATGATEWAY_ID] (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'Name of the data center'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Deletes an existing NAT Gateway.'
        @required_options = [:datacenter_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        natgateways_api = Ionoscloud::NATGatewaysApi.new(api_client)
        @name_args.each do |natgateway_id|
          begin
            natgateway = natgateways_api.datacenters_natgateways_find_by_nat_gateway_id(config[:datacenter_id], natgateway_id, depth: 2)
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("NAT Gateway ID #{natgateway_id} not found. Skipping.")
            next
          end

          msg_pair('ID', natgateway.id)
          msg_pair('Name', natgateway.properties.name)
          msg_pair('IPS', natgateway.properties.public_ips)
          msg_pair('LANS', natgateway.properties.lans.map { |el| { id: el.id, gateway_ips: el.gateway_ips } })
          msg_pair('Rules', natgateway.entities.rules.items.map do |el|
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
            end
          )

          begin
            confirm('Do you really want to delete this NAT Gateway')
          rescue SystemExit => exc
            next
          end

          _, _, headers = natgateways_api.datacenters_natgateways_delete_with_http_info(config[:datacenter_id], natgateway.id)
          ui.warn("Deleted NAT Gateway #{natgateway.id}. Request ID: #{get_request_id headers}")
        end
      end
    end
  end
end
