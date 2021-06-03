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

      option :server_id,
              short: '-S SERVER_ID',
              long: '--server-id SERVER_ID',
              description: 'The ID of the server'

      option :nic_id,
              short: '-N NIC_ID',
              long: '--nic-id NIC_ID',
              description: 'ID of the NIC'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Lists all available flow logs assigned to a NIC.'
        @required_options = [:datacenter_id, :server_id, :nic_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        validate_required_params(@required_options, config)

        flowlog_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Action', :bold),
          ui.color('Direction', :bold),
          ui.color('Bucket', :bold),
        ]

        flowlogs_api = Ionoscloud::FlowLogsApi.new(api_client)

        flowlogs_api.datacenters_servers_nics_flowlogs_get(
          config[:datacenter_id], config[:server_id], config[:nic_id], { depth: 1 }
        ).items.each do |flowlog|
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
