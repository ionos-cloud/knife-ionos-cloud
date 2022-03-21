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
        @directory = 'application-loadbalancers'
        @required_options = [:ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        target_group_api = Ionoscloud::TargetGroupsApi.new(api_client)

        @name_args.each do |target_group_id|
          begin
            target_group = target_group_api.targetgroups_find_by_target_group_id(target_group_id)
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("Target Group ID #{target_group_id} not found. Skipping.")
            next
          end

          print_target_group(target_group)
          puts "\n"

          begin
            confirm('Do you really want to delete this Target Group')
          rescue SystemExit
            next
          end

          _, _, headers = target_group_api.target_groups_delete_with_http_info(target_group_id)
          ui.warn("Deleted Target Group #{target_group.id}. Request ID: #{get_request_id headers}")
        end
      end
    end
  end
end
