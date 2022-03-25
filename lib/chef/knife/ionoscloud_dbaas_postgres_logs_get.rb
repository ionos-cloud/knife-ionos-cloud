require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudDbaasPostgresLogsGet < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud dbaas postgres logs get'

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
              description: 'The start time for the query in RFC3339 format. '\
              'Can also be specified as a time delta since the current moment: 2h - 2 hours ago, 20m - 20 minutes ago. '\
              'Only hours and minutes ar supported, and not at the same time.'

      option :end,
              long: '--end END',
              description: 'The end time for the query in RFC3339 format. '\
              'Can also be specified as a time delta since the current moment: 2h - 2 hours ago, 20m - 20 minutes ago. '\
              'Only hours and minutes ar supported, and not at the same time.'

      option :direction,
              long: '--direction DIRECTION',
              description: 'The direction in which to scan through the logs. '\
                           'The logs are returned in order of the direction. One of ["BACKWARD", "FORWARD"]'

      def initialize(args = [])
        super(args)
        @description =
        'Retrieves PostgreSQL logs based on the given parameters.'
        @directory = 'dbaas-postgres'
        @required_options = [:cluster_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        match_time_delta = /^\d+\D$/

        def delta_to_date(delta)
          unit = delta[-1]
          unless ['h', 'm'].include? unit
            ui.error('Time delta may only be specified in hours(h) or minutes(m)!')
            exit(1)
          end

          minute_count = Integer(delta[..-2])
          minute_count *= 60 if unit == 'h'
           
          (Time.now - minute_count * 60).iso8601
        end

        if config[:start] && config[:start].match(match_time_delta)
          config[:start] = delta_to_date(config[:start])
        end
        if config[:end] && config[:end].match(match_time_delta)
          config[:end] = delta_to_date(config[:end])
        end


        logs = IonoscloudDbaasPostgres::LogsApi.new(api_client_dbaas).cluster_logs_get(
          config[:cluster_id],
          {
            limit: (config[:limit] != nil ? Integer(config[:limit]) : nil),
            start: config[:start],
            end: config[:end],
            direction: config[:direction],
          },
        )

        logs.instances.each do |instance|
          puts "Instance Name: #{instance.name}"
          print "\n"
          puts instance.messages.map { |message| message.message }
          puts "\n"
        end
      end
    end
  end
end
