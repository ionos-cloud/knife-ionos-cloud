require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudTargetgroupCreate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud targetgroup create (options)'

      option :name,
              short: '-n NAME',
              long: '--name NAME',
              description: 'Name of the server'

      option :algorithm,
              short: '-a ALGORITHM',
              long: '--algorithm ALGORITHM',
              description: 'Algorithm for the balancing. One of ["ROUND_ROBIN", "LEAST_CONNECTION", "RANDOM", "SOURCE_IP"]'

      option :protocol,
              short: '-p PROTOCOL',
              long: '--protocol PROTOCOL',
              description: 'Protocol of the balancing. One of ["HTTP"]'

      option :check_timeout,
              long: '--check-timeout CHECK_TIMEOUT',
              description: 'It specifies the time (in milliseconds) for a target VM in this pool to answer the check. If '\
              'a target VM has CheckInterval set and CheckTimeout is set too, then the smaller value of the two is used '\
              'after the TCP connection is established.'

      option :connect_timeout,
              long: '--connect-timeout CONNECT_TIMEOUT',
              description: 'It specifies the maximum time (in milliseconds) to wait for a connection attempt to a target '\
              'VM to succeed. If unset, the default of 5 seconds will be used.'

      option :target_timeout,
              long: '--target-timeout TARGET_TIMEOUT',
              description: 'TargetTimeout specifies the maximum inactivity time (in milliseconds) on the target VM side. '\
              'If unset, the default of 50 seconds will be used.'

      option :retries,
              short: '-r RETRIES',
              long: '--retries RETRIES',
              description: 'Retries specifies the number of retries to perform on a target VM after a connection failure. '\
              'If unset, the default value of 3 will be used. (valid range: [0, 65535])'

      option :path,
              long: '--path PATH',
              description: 'The path for the HTTP health check; default: /.'

      option :method,
              short: '-m METHOD',
              long: '--method METHOD',
              description: 'The method for the HTTP health check.'

      option :match_type,
              long: '--match-type MATCH_TYPE',
              description: 'The method for the HTTP health check. One of ["STATUS_CODE", "RESPONSE_BODY"].'

      option :response,
              long: '--response RESPONSE',
              description: 'The response returned by the request.'

      option :regex,
              long: '--regex REGEX',
              description: 'The regex used.'

      option :negate,
              long: '--negate',
              description: 'Whether to negate or not.'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Creates a new Target Group.'
        @required_options = [:name, :algorithm, :protocol, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        validate_required_params(@required_options, config)

        target_groups_api = Ionoscloud::TargetGroupsApi.new(api_client)

        target_group_properties = {
          name: config[:name],
          algorithm: config[:algorithm],
          protocol: config[:protocol],
          health_check: Ionoscloud::TargetGroupHealthCheck.new(
            check_timeout: config[:check_timeout],
            connect_timeout: config[:connect_timeout],
            target_timeout: config[:target_timeout],
            retries: config[:retries],
          ),
          http_health_check: Ionoscloud::TargetGroupHttpHealthCheck.new(
            path: config[:path],
            method: config[:method],
            match_type: config[:match_type],
            response: config[:response],
            regex: config[:regex],
            negate: config[:negate],
          ),
        }

        target_group = Ionoscloud::TargetGroup.new(
          properties: Ionoscloud::TargetGroupProperties.new(
            **target_group_properties.compact,
          ),
        )

        target_group, _, headers = target_groups_api.targetgroups_post_with_http_info(target_group)

        print "#{ui.color('Creating Target Group...', :magenta)}"
        dot = ui.color('.', :magenta)
        api_client.wait_for { print dot; is_done? get_request_id headers }

        target_group = target_groups_api.targetgroups_find_by_target_group_id(target_group.id)

        health_check, http_health_check, _ = get_target_group_extended_properties(target_group)

        puts "\n"
        puts "#{ui.color('ID', :cyan)}: #{target_group.id}"
        puts "#{ui.color('Name', :cyan)}: #{target_group.properties.name}"
        puts "#{ui.color('Algorithm', :cyan)}: #{target_group.properties.algorithm}"
        puts "#{ui.color('Protocol', :cyan)}: #{target_group.properties.protocol}"
        puts "#{ui.color('Health Check', :cyan)}: #{health_check}"
        puts "#{ui.color('HTTP Health Check', :cyan)}: #{http_health_check}"

        puts 'done'
      end
    end
  end
end
