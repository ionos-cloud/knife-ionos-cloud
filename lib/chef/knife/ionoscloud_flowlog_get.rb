require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudFlowlogGet < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud flowlog get (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'The ID of the data center'

      option :type,
              short: '-t FLOWLOG_TYPE',
              long: '--type FLOWLOG_TYPE',
              description: 'The object to which the Flow Log will be attached'

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

      option :flowlog_id,
              short: '-F FLOWLOG_ID',
              long: '--flowlog-id FLOWLOG_ID',
              description: 'The ID of the Flow Log'

      def initialize(args = [])
        super(args)
        @description =
        'Retrieves information about a Ionoscloud Flow Log.'
        @directory = 'compute-engine'
        @required_options = [:flowlog_id, :datacenter_id, :type]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        case config[:type]
        when 'nic'
          validate_required_params([:server_id, :nic_id], config)
          flowlog = Ionoscloud::FlowLogsApi.new(api_client).datacenters_servers_nics_flowlogs_find_by_id(
            config[:datacenter_id], config[:server_id], config[:nic_id], config[:flowlog_id],
          )
        when 'natgateway'
          validate_required_params([:natgateway_id], config)
          flowlog = Ionoscloud::NATGatewaysApi.new(api_client).datacenters_natgateways_flowlogs_find_by_flow_log_id(
            config[:datacenter_id], config[:natgateway_id], config[:flowlog_id],
          )
        when 'networkloadbalancer'
          validate_required_params([:network_loadbalancer_id], config)
          flowlog = Ionoscloud::NetworkLoadBalancersApi.new(api_client).datacenters_networkloadbalancers_flowlogs_find_by_flow_log_id(
            config[:datacenter_id], config[:network_loadbalancer_id], config[:flowlog_id],
          )
        else
          ui.error "Flow Log cannot belong to #{config[:type]}. Value must be one of ['nic', 'natgateway', 'networkloadbalancer']"
          exit(1)
        end

        print_flowlog(flowlog)
      end
    end
  end
end
