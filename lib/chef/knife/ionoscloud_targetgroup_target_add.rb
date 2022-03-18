require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudTargetgroupTargetAdd < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud targetgroup target add (options)'

      option :target_group_id,
              short: '-T TARGET_GROUP_ID',
              long: '--target-group-id TARGET_GROUP_ID',
              description: 'ID of the Target Group'

      option :ip,
              long: '--ip IP',
              description: 'IP of a balanced target VM'

      option :port,
              short: '-p PORT',
              long: '--port PORT',
              description: 'Port of the balanced target service. (range: 1 to 65535)'

      option :weight,
              short: '-w WEIGHT',
              long: '--weight WEIGHT',
              description: 'Weight parameter is used to adjust the target VM\'s weight relative to other target VMs. '\
              'All target VMs will receive a load proportional to their weight relative to the sum of all weights, '\
              'so the higher the weight, the higher the load. The default weight is 1, and the maximal value is 256. '\
              'A value of 0 means the target VM will not participate in load-balancing but will still accept persistent '\
              'connections. If this parameter is used to distribute the load according to target VM\'s capacity, it is '\
              'recommended to start with values which can both grow and shrink, for instance between 10 and 100 to leave '\
              'enough room above and below for later adjustments.'

      option :health_check_disable,
              long: '--health-check-disable',
              description: 'Enabling the health check makes the target available only if it accepts periodic health check '\
              'TCP connection attempts; when turned off, the target is considered always available. The health check only '\
              'consists of a connection attempt to the address and port of the target. Default is having the health check enabled.',
              boolean: true

      option :maintenance_enabled,
              long: '--maintenance',
              description: 'Maintenance mode prevents the target from receiving balanced traffic.',
              boolean: true

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Adds a Target to a Target Group.'
        @required_options = [:target_group_id, :ip, :port, :weight, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        target_groups_api = Ionoscloud::TargetGroupsApi.new(api_client)

        target_group = target_groups_api.targetgroups_find_by_target_group_id(config[:target_group_id])

        existing_target = target_group.properties.targets.find do |target|
          target.ip == config[:ip] && target.port == Integer(config[:port])
        end

        if existing_target
          ui.warn("Specified target already exists (#{existing_target}).")
        else
          target_group.properties.targets.append(
            Ionoscloud::TargetGroupTarget.new(
              ip: config[:ip],
              port: Integer(config[:port]),
              weight: Integer(config[:weight]),
              health_check_enabled: !config[:health_check_disable],
              maintenance_enabled: config[:maintenance_enabled],
            ),
          )

          _, _, headers = target_groups_api.targetgroups_patch_with_http_info(config[:target_group_id], target_group.properties)
          print "#{ui.color('Adding the Target to the Target Group...', :magenta)}"
          dot = ui.color('.', :magenta)
          api_client.wait_for { print dot; is_done? get_request_id headers }
        end

        print_target_group(target_groups_api.targetgroups_find_by_target_group_id(config[:target_group_id]))
      end
    end
  end
end
