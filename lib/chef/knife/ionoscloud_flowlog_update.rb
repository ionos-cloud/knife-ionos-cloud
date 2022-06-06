require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudFlowlogUpdate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud flowlog update (options)'

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

      option :name,
              short: '-n NAME',
              long: '--name NAME',
              description: 'Name of the Flow Log'

      option :action,
              short: '-a ACTION',
              long: '--action ACTION',
              description: 'Specifies the traffic action pattern. Must be one of ["ALL", "ACCEPTED", "REJECTED"].'

      option :direction,
              long: '--direction DIRECTION',
              description: 'Specifies the traffic direction pattern. Must be one of ["INGRESS", "EGRESS", "BIDIRECTIONAL"].'

      option :bucket,
              short: '-b BUCKET',
              long: '--bucket BUCKET',
              description: 'S3 bucket name of an existing IONOS Cloud S3 bucket. Ex. bucketName/key'

      def initialize(args = [])
        super(args)
        @description =
        'Updates information about a Ionoscloud Flow Log.'
        @directory = 'compute-engine'
        @required_options = [:flowlog_id, :datacenter_id, :type]
        @updatable_fields = [:name, :action, :direction, :bucket]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        case config[:type]
        when 'nic'
          validate_required_params([:server_id, :nic_id], config)
          flowlogs_api = Ionoscloud::FlowLogsApi.new(api_client)
          patch_method = flowlogs_api.method(:datacenters_servers_nics_flowlogs_patch_with_http_info)
          get_method = flowlogs_api.method(:datacenters_servers_nics_flowlogs_find_by_id)
          args = [config[:datacenter_id], config[:server_id], config[:nic_id], config[:flowlog_id]]
        when 'natgateway'
          validate_required_params([:natgateway_id], config)
          flowlogs_api = Ionoscloud::NATGatewaysApi.new(api_client)
          patch_method = flowlogs_api.method(:datacenters_natgateways_flowlogs_patch_with_http_info)
          get_method = flowlogs_api.method(:datacenters_natgateways_flowlogs_find_by_flow_log_id)
          args = [config[:datacenter_id], config[:natgateway_id], config[:flowlog_id]]
        when 'networkloadbalancer'
          validate_required_params([:network_loadbalancer_id], config)
          flowlogs_api = Ionoscloud::NetworkLoadBalancersApi.new(api_client)
          patch_method = flowlogs_api.method(:datacenters_networkloadbalancers_flowlogs_patch_with_http_info)
          get_method = flowlogs_api.method(:datacenters_networkloadbalancers_flowlogs_find_by_flow_log_id)
          args = [config[:datacenter_id], config[:network_loadbalancer_id], config[:flowlog_id]]
        else
          ui.error "Flow Log cannot belong to #{config[:type]}. Value must be one of ['nic', 'natgateway', 'networkloadbalancer']"
          exit(1)
        end

        if @updatable_fields.map { |el| config[el] }.any?
          print "#{ui.color('Updating Flow Log...', :magenta)}"

          flowlog_properties = Ionoscloud::FlowLogProperties.new({
            name: config[:name],
            action: config[:action],
            direction: config[:direction],
            bucket: config[:bucket],
          }.compact)

          _, _, headers  = patch_method.call(*args, flowlog_properties)

          dot = ui.color('.', :magenta)
          api_client.wait_for { print dot; is_done? get_request_id headers }
        else
          ui.warn("Nothing to update, please set one of the attributes #{@updatable_fields}.")
        end

        print_flowlog(get_method.call(*args))
      end
    end
  end
end
