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

      option :check,
              long: '--check',
              description: 'Check specifies whether the target VM\'s health is checked. If turned off, a target VM is '\
              'always considered available. If turned on, the target VM is available when accepting periodic TCP connections, '\
              'to ensure that it is really able to serve requests. The address and port to send the tests to are those of the '\
              'target VM. The health check only consists of a connection attempt. If unspecified the default value: true is used.'

      option :check_interval,
              long: '--check-interval CHECK_INTERVAL',
              description: 'CheckInterval determines the duration (in milliseconds) between consecutive health checks. If '\
              'unspecified a default of 2000 ms is used.'

      option :maintenance,
              long: '--maintenance',
              description: 'Maintenance specifies if a target VM should be marked as down, even if it is not.'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Adds a Target to a Target Group or updates an exisiting one inside the group.'
        @required_options = [:target_group_id, :ip, :port, :weight, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        validate_required_params(@required_options, config)

        target_groups_api = Ionoscloud::TargetGroupsApi.new(api_client)

        target_group = target_groups_api.target_groups_find_by_id(config[:target_group_id])

        existing_target = target_group.properties.targets.find do
          |target|
          target.ip == config[:ip] && target.port == Integer(config[:port])
        end

        if existing_target
          existing_target.weigth = Integer(config[:weigth])
          existing_target.health_check = Ionoscloud::TargetGroupTargetHealthCheck.new(
            check: config[:check] || existing_target.health_check.check,
            check_interval: config[:check_interval] || existing_target.health_check.check_interval,
            maintenance: config[:maintenance] || existing_target.health_check.maintenance,
          ),
        else
          target_group.targets.append(
            Ionoscloud::TargetGroupTarget.new(
              ip: config[:ip],
              port: config[:port],
              weight: config[:weight],
              health_check: Ionoscloud::TargetGroupTargetHealthCheck.new(
                check: config[:check],
                check_interval: config[:check_interval],
                maintenance: config[:maintenance],
              ),
            )
          )
        end

        _, _, headers = target_groups_api.target_groups_patch_with_http_info(config[:target_group_id], target_group.properties)

        print "#{ui.color('Adding the Target to the Target Group...', :magenta)}"
        dot = ui.color('.', :magenta)
        api_client.wait_for { print dot; is_done? get_request_id headers }

        target_group = target_groups_api.target_groups_find_by_id(config[:target_group_id])

        health_check = {
          check_timeout: target_group.properties.health_check.check_timeout,
          connect_timeout: target_group.properties.health_check.connect_timeout,
          target_timeout: target_group.properties.health_check.target_timeout,
          retries: target_group.properties.health_check.retries,
        }
        http_health_check = {
          path: target_group.properties.http_health_check.path,
          method: target_group.properties.http_health_check.method,
          match_type: target_group.properties.http_health_check.match_type,
          response: target_group.properties.http_health_check.response,
          regex: target_group.properties.http_health_check.regex,
          negate: target_group.properties.http_health_check.negate,
        }
        targets = target_group.properties.targets.nil? ? [] : target_group.properties.targets.map do
          |target|
          {
            ip: target.ip,
            port: target.port,
            weight: target.weight,
            health_check: target.health_check.nil? ? nil : Ionoscloud::TargetGroupTargetHealthCheck.new(
              check: target.health_check.check,
              check_interval: target.health_check.check_interval,
              maintenance: target.health_check.maintenance,
            )
          }
        end

        puts "\n"
        puts "#{ui.color('ID', :cyan)}: #{target_group.id}"
        puts "#{ui.color('Name', :cyan)}: #{target_group.properties.name}"
        puts "#{ui.color('Algorithm', :cyan)}: #{target_group.properties.algorithm}"
        puts "#{ui.color('Protocol', :cyan)}: #{target_group.properties.protocol}"
        puts "#{ui.color('Health Check', :cyan)}: #{health_check}"
        puts "#{ui.color('HTTP Health Check', :cyan)}: #{http_health_check}"
        puts "#{ui.color('Targets', :cyan)}: #{targets}"
        puts 'done'
      end
    end
  end
end
