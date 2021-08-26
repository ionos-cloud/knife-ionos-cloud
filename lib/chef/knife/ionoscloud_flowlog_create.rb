require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudFlowlogCreate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud flowlog create (options)'

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
              description: 'ID of the server'

      option :nic_id,
              short: '-N NIC_ID',
              long: '--nic-id NIC_ID',
              description: 'ID of the NIC'

      option :natgateway_id,
              short: '-G NAT_GATEWAY_ID',
              long: '--natgateway NAT_GATEWAY_ID',
              description: 'ID of the NAT Gateway'

      option :network_loadbalancer_id,
              short: '-L NETWORK_LOADBALANCER',
              long: '--network-loadbalancer NETWORK_LOADBALANCER',
              description: 'ID of the Network Load Balancer'

      option :name,
              short: '-n NAME',
              long: '--name NAME',
              description: 'Name of the Flow Log'

      option :action,
              short: '-a ACTION',
              long: '--action ACTION',
              default: 'ALL',
              description: 'Specifies the traffic action pattern. Must be one of ["ALL", "ACCEPTED", "REJECTED"].'

      option :direction,
              long: '--direction DIRECTION',
              default: 'BIDIRECTIONAL',
              description: 'Specifies the traffic direction pattern. Must be one of ["INGRESS", "EGRESS", "BIDIRECTIONAL"].'

      option :bucket,
              short: '-b BUCKET',
              long: '--bucket BUCKET',
              description: 'S3 bucket name of an existing IONOS Cloud S3 bucket. Ex. bucketName/key'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'This will add a Flow Log to the network interface, NAT Gateway or Network Load Balancer.'
        @required_options = [:datacenter_id, :type, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        print "#{ui.color('Creating flow log...', :magenta)}"

        case config[:type]
        when 'nic'
          validate_required_params([:server_id, :nic_id], config)
          flowlogs_api = Ionoscloud::FlowLogsApi.new(api_client)
          method = flowlogs_api.method(:datacenters_servers_nics_flowlogs_post_with_http_info)
          args = [config[:datacenter_id], config[:server_id], config[:nic_id]]
        when 'natgateway'
          validate_required_params([:natgateway_id], config)
          flowlogs_api = Ionoscloud::NATGatewaysApi.new(api_client)
          method = flowlogs_api.method(:datacenters_natgateways_flowlogs_post_with_http_info)
          args = [config[:datacenter_id], config[:natgateway_id]]
        when 'loadbalancer'
          validate_required_params([:network_loadbalancer_id], config)
          flowlogs_api = Ionoscloud::NetworkLoadBalancersApi.new(api_client)
          method = flowlogs_api.method(:datacenters_networkloadbalancers_flowlogs_post_with_http_info)
          args = [config[:datacenter_id], config[:network_loadbalancer_id]]
        else
          ui.error "Flow log cannot belong to #{config[:type]}. Value must be one of ['nic', 'natgateway', 'loadbalancer']"
          exit(1)
        end

        flowlog = Ionoscloud::FlowLog.new(
          properties: Ionoscloud::FlowLogProperties.new({
            name: config[:name],
            action: config[:action],
            direction: config[:direction],
            bucket: config[:bucket],
          }.compact),
        )

        flowlog, _, headers = method.call(*args, flowlog)

        dot = ui.color('.', :magenta)
        api_client.wait_for { print dot; is_done? get_request_id headers }

        puts "\n"
        puts "#{ui.color('ID', :cyan)}: #{flowlog.id}"
        puts "#{ui.color('Name', :cyan)}: #{flowlog.properties.name}"
        puts "#{ui.color('Action', :cyan)}: #{flowlog.properties.action}"
        puts "#{ui.color('Direction', :cyan)}: #{flowlog.properties.direction}"
        puts "#{ui.color('Bucket', :cyan)}: #{flowlog.properties.bucket}"
        puts 'done'
      end
    end
  end
end
