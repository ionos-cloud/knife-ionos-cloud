require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudFlowlogList < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud flowlog list (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'ID of the data center'

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

      def initialize(args = [])
        super(args)
        @description =
        'Lists all available flow logs assigned to a NIC, NAT Gateway or Network Load Balancer.'
        @directory = 'compute-engine'
        @required_options = [:datacenter_id, :type, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        flowlog_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Action', :bold),
          ui.color('Direction', :bold),
          ui.color('Bucket', :bold),
        ]
        flowlogs = []

        case config[:type]
        when 'nic'
          validate_required_params([:server_id, :nic_id], config)
          flowlogs_api = Ionoscloud::FlowLogsApi.new(api_client)
          flowlogs = flowlogs_api.datacenters_servers_nics_flowlogs_get(
            config[:datacenter_id], config[:server_id], config[:nic_id], { depth: 1 },
          )
        when 'natgateway'
          validate_required_params([:natgateway_id], config)
          flowlogs_api = Ionoscloud::NATGatewaysApi.new(api_client)
          flowlogs = flowlogs_api.datacenters_natgateways_flowlogs_get(
            config[:datacenter_id], config[:natgateway_id], { depth: 1 },
          )
        when 'networkloadbalancer'
          validate_required_params([:network_loadbalancer_id], config)
          flowlogs_api = Ionoscloud::NetworkLoadBalancersApi.new(api_client)
          flowlogs = flowlogs_api.datacenters_networkloadbalancers_flowlogs_get(
            config[:datacenter_id], config[:network_loadbalancer_id], { depth: 1 },
          )
        else
          ui.error "Flow log cannot belong to #{config[:type]}. Value must be one of ['nic', 'natgateway', 'networkloadbalancer']"
          exit(1)
        end

        flowlogs.items.each do |flowlog|
          flowlog_list << flowlog.id
          flowlog_list << flowlog.properties.name
          flowlog_list << flowlog.properties.action.to_s
          flowlog_list << flowlog.properties.direction.to_s
          flowlog_list << flowlog.properties.bucket.to_s
        end

        puts ui.list(flowlog_list, :uneven_columns_across, 5)
      end
    end
  end
end
