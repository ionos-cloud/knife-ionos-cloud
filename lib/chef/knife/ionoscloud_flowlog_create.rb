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

      option :server_id,
              short: '-S SERVER_ID',
              long: '--server-id SERVER_ID',
              description: 'ID of the server'

      option :nic_id,
              short: '-N NIC_ID',
              long: '--nic-id NIC_ID',
              description: 'ID of the NIC'

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
              short: '-d DIRECTION',
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
        'This will add a Flow Log to the network interface.'
        @required_options = [:datacenter_id, :server_id, :nic_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        validate_required_params(@required_options, config)

        print "#{ui.color('Creating flow log...', :magenta)}"

        flowlog = Ionoscloud::FlowLog.new(
          properties: Ionoscloud::FlowLogProperties.new({
            name: config[:name],
            action: config[:action],
            direction: config[:direction],
            bucket: config[:action],
          }.compact),
        )

        flowlogs_api = Ionoscloud::FlowLogsApi.new(api_client)

        flowlog, _, headers = flowlogs_api.datacenters_servers_nics_flowlogs_post_with_http_info(
          config[:datacenter_id],
          config[:server_id],
          config[:nic_id],
          flowlog,
        )

        dot = ui.color('.', :magenta)
        api_client.wait_for { print dot; is_done? get_request_id headers }

        flowlog = flowlogs_api.datacenters_servers_nics_flowlogs_find_by_id(
          config[:datacenter_id],
          config[:server_id],
          config[:nic_id],
          flowlog.id,
        )

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
