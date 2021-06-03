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
        'Removes the specified Flow Logs.'
        @required_options = [:datacenter_id, :server_id, :nic_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        validate_required_params(@required_options, config)

        flowlogs_api = Ionoscloud::FlowLogsApi.new(api_client)

        @name_args.each do |flowlog_id|
          begin
            firewall = flowlogs_api.datacenters_servers_nics_flowlogs_find_by_id(
              config[:datacenter_id], config[:server_id], config[:nic_id], flowlog_id,
            )
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

          _, _, headers = flowlogs_api.datacenters_servers_nics_flowlogs_delete_with_http_info(
            config[:datacenter_id], config[:server_id], config[:nic_id], flowlog_id,
          )
          ui.warn("Deleted flow log #{firewall.id}. Request ID: #{get_request_id headers}")
        end
      end
    end
  end
end
