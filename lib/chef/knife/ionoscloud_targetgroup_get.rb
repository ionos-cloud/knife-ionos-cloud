require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudTargetgroupGet < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud targetgroup get (options)'

      option :target_group_id,
              short: '-T TARGET_GROUP_ID',
              long: '--target-group-id TARGET_GROUP_ID',
              description: 'ID of the Target Group'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Gets information about a Target Group.'
        @required_options = [:target_group_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        validate_required_params(@required_options, config)

        target_groups_api = Ionoscloud::TargetGroupsApi.new(api_client)

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
