require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudTargetgroupDelete < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud targetgroup delete TARGET_GROUP_ID [TARGET_GROUP_ID]'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Deletes a Target Group'
        @required_options = [:ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        validate_required_params(@required_options, config)

        target_group_api = Ionoscloud::TargetGroupsApi.new(api_client)

        @name_args.each do |target_group_id|
          begin
            target_group = target_group_api.target_groups_find_by_id(target_group_id)
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("Target Group ID #{target_group_id} not found. Skipping.")
            next
          end

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

          msg_pair('ID', target_group.id)
          msg_pair('Name', target_group.properties.name)
          msg_pair('Algorithm', target_group.properties.algorithm)
          msg_pair('Protocol', target_group.properties.protocol)
          msg_pair('Health Check', health_check)
          msg_pair('HTTP Health Check', http_health_check)
          msg_pair('Targets', targets)

          puts "\n"

          begin
            confirm('Do you really want to delete this Target Group')
          rescue SystemExit => exc
            next
          end

          _, _, headers = target_group_api.target_groups_delete_with_http_info(target_group_id)
          ui.warn("Deleted Target Group #{target_group.id}. Request ID: #{get_request_id headers}")
        end
      end
    end
  end
end
