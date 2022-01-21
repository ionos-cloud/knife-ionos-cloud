require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudDbaasLogsGet < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud dbaas logs get'

      option :cluster_id,
              short: '-C CLUSTER_ID',
              long: '--cluster-id CLUSTER_ID',
              description: 'ID of the cluster'

      option :limit,
              short: '-l LIMIT',
              long: '--limit LIMIT',
              description: 'The maximal number of log lines to return.'

      option :start,
              long: '--start START',
              description: 'The start time for the query in RFC3339 format.'

      option :end,
              long: '--end END',
              description: 'The end time for the query in RFC3339 format.'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Retrieves PostgreSQL logs based on the given parameters.'
        @required_options = [:cluster_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        logs = IonoscloudDbaas::LogsApi.new(api_client_dbaas).cluster_logs_get(
          config[:cluster_id],
          {
            limit: Integer(config[:limit]),
            start: config[:start],
            end: config[:end],
          },
        )

        logs.instances.each { |instance|
          puts "Instance Name: #{instance.name}"
          print "\n"
          puts instance.messages.map { |message| message.message }
          puts "\n"
        }
      end
    end
  end
end
