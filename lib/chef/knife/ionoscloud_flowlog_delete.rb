require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudFlowlogDelete < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud flowlog delete FLOWLOG_ID [FLOWLOG_ID] (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'The ID of the data center'

      option :type,
              short: '-t FLOWLOG_TYPE',
              long: '--type FLOWLOG_TYPE',
              description: 'The object to which the flow log will be attached'

      option :server_id,
              short: '-S SERVER_ID',
              long: '--server-id SERVER_ID',
              description: 'The ID of the server'

      option :nic_id,
              short: '-N NIC_ID',
              long: '--nic-id NIC_ID',
              description: 'ID of the NIC'

      option :natgateway_id,
              short: '-G NAT_GATEWAY_ID',
              long: '--nat-gateway NAT_GATEWAY_ID',
              description: 'ID of the NAT Gateway'

      option :network_loadbalancer_id,
              short: '-L NETWORK_LOADBALANCER',
              long: '--network-loadbalancer NETWORK_LOADBALANCER',
              description: 'ID of the Network Load Balancer'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Removes the specified Flow Logs.'
        @required_options = [:datacenter_id, :type, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        flowlogs_api = Ionoscloud::FlowLogsApi.new(api_client)

        case config[:type]
        when 'nic'
          validate_required_params([:server_id, :nic_id], config)
          flowlogs_api = Ionoscloud::FlowLogsApi.new(api_client)
          delete_method = flowlogs_api.method(:datacenters_servers_nics_flowlogs_delete_with_http_info)
          get_method = flowlogs_api.method(:datacenters_servers_nics_flowlogs_find_by_id)
          args = [config[:datacenter_id], config[:server_id], config[:nic_id]]
        when 'natgateway'
          validate_required_params([:natgateway_id], config)
          flowlogs_api = Ionoscloud::NATGatewaysApi.new(api_client)
          delete_method = flowlogs_api.method(:datacenters_natgateways_flowlogs_delete_with_http_info)
          get_method = flowlogs_api.method(:datacenters_natgateways_flowlogs_find_by_flow_log_id)
          args = [config[:datacenter_id], config[:natgateway_id]]
        when 'loadbalancer'
          validate_required_params([:network_loadbalancer_id], config)
          flowlogs_api = Ionoscloud::NetworkLoadBalancersApi.new(api_client)
          delete_method = flowlogs_api.method(:datacenters_networkloadbalancers_flowlogs_delete_with_http_info)
          get_method = flowlogs_api.method(:datacenters_networkloadbalancers_flowlogs_find_by_flow_log_id)
          args = [config[:datacenter_id], config[:network_loadbalancer_id]]
        else
          ui.error "Flow log cannot belong to #{config[:type]}. Value must be one of ['nic', 'natgateway', 'loadbalancer']"
          exit(1)
        end

        @name_args.each do |flowlog_id|
          begin
            firewall = get_method.call(*args, flowlog_id)
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("Flow log ID #{flowlog_id} not found. Skipping.")
            next
          end

          msg_pair('ID', firewall.id)
          msg_pair('Name', firewall.properties.name)
          msg_pair('Action', firewall.properties.action)
          msg_pair('Direction', firewall.properties.direction)
          msg_pair('Bucket', firewall.properties.bucket)

          begin
            confirm('Do you really want to delete this flow log')
          rescue SystemExit => exc
            next
          end

          _, _, headers = delete_method.call(*args, flowlog_id)
          ui.warn("Deleted flow log #{firewall.id}. Request ID: #{get_request_id headers}")
        end
      end
    end
  end
end
