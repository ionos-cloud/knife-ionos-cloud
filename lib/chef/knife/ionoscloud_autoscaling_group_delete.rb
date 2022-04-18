require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudVmAutoscalingGroupCDelete < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud vm autoscaling group delete GROUP_ID [GROUP_ID]'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Delete a Ionoscloud vm Autoscaling Group'
        @required_options = [:ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        groups_api = IonoscloudAutoscaling::GroupsApi.new(api_client)

        @name_args.each do |group_id|
          begin
            group = groups_api.autoscaling_groups_find_by_id(group_id)
          rescue IonoscloudAutoscaling::ApiError => err
            raise err unless err.code == 404
            ui.error("Group ID #{group_id} not found. Skipping.")
            next
          end

          print_autoscaling_group(group)
          puts "\n"

          begin
            confirm('Do you really want to delete this group')
          rescue SystemExit => exc
            next
          end

          _, _, headers = groups_api.autoscaling_groups_delete_with_http_info(group_id)
          ui.warn("Deleted Group #{group.id}. Request ID: #{get_request_id headers}")
        end
      end
    end
  end
end