require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudTargetgroupUpdate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud targetgroup update (options)'

      option :target_group_id,
              short: '-T TARGET_GROUP_ID',
              long: '--target-group-id TARGET_GROUP_ID',
              description: 'ID of the Target Group'

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

      option :check_interval,
              long: '--check-interval check_interval',
              description: 'It specifies the maximum time (in milliseconds) to wait for a connection attempt to a target '\
              'VM to succeed. If unset, the default of 5 seconds will be used.'

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

      option :targets,
              long: '--targets',
              description: 'Array of TargetGroup targets.'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Updates information about a Ionoscloud Application LoadBalancer.'
        @required_options = [:target_group_id, :ionoscloud_username, :ionoscloud_password]
        @updatable_fields = [
          :name, :algorithm, :protocol, :check_timeout, :connect_timeout, :target_timeout,
          :retries, :path, :method, :match_type, :response, :regex, :negate, :targets,
        ]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        target_groups_api = Ionoscloud::TargetGroupsApi.new(api_client)

        if @updatable_fields.map { |el| config[el] }.any?
          print "#{ui.color('Updating Target Group...', :magenta)}"

          unless config[:targets].nil?
            config[:targets] = JSON[config[:targets]] if config[:targets].instance_of?(String)

            config[:targets].map! do |target|
              Ionoscloud::TargetGroupTarget.new(
                ip: target['ip'],
                port: Integer(target['port']),
                weight: Integer(target['weight']),
                health_check_enabled: target['health_check_enabled'],
                maintenance_enabled: target['maintenance_enabled'],
              )
            end
          end

          send_http_health_check = config[:path] || config[:method] || config[:match_type] || config[:response] || config[:regex] || config[:negate]

          target_group_properties = {
            name: config[:name],
            algorithm: config[:algorithm],
            protocol: config[:protocol],
            targets: config[:targets],
            health_check: Ionoscloud::TargetGroupHealthCheck.new(
              check_timeout: config[:check_timeout],
              check_interval: config[:check_interval],
              retries: config[:retries],
            ),
            http_health_check: send_http_health_check ? Ionoscloud::TargetGroupHttpHealthCheck.new(
              path: config[:path],
              method: config[:method],
              match_type: config[:match_type],
              response: config[:response],
              regex: config[:regex],
              negate: config[:negate],
            ) : nil,
          }

          _, _, headers  = target_groups_api.targetgroups_patch_with_http_info(
            config[:target_group_id],
            Ionoscloud::TargetGroupProperties.new(**target_group_properties.compact),
          )

          dot = ui.color('.', :magenta)
          api_client.wait_for { print dot; is_done? get_request_id headers }
        else
          ui.warn("Nothing to update, please set one of the attributes #{@updatable_fields}.")
        end

        print_target_group(Ionoscloud::TargetGroupsApi.new(api_client).targetgroups_find_by_target_group_id(config[:target_group_id]))
      end
    end
  end
end
