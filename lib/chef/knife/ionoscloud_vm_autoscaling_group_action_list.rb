require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudVmAutoscalingGroupActionList < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud vm autoscaling group action list'

      option :group_id,
              short: '-G GROUP_ID',
              long: '--group-id GROUP_ID',
              description: 'ID of the vm autoscaling group'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Retrieves a list of all VM Autoscaling Group actions.'
        @required_options = [:group_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        autoscaling_group_action_list = [
          ui.color('ID', :bold),
          ui.color('Status', :bold),
          ui.color('Type', :bold),
          ui.color('Target Replicas', :bold),
        ]

        groups_api = IonoscloudVmAutoscaling::GroupsApi.new(api_client_vm_autoscaling)

        groups_api.autoscaling_groups_actions_get(config[:group_id], depth: 1).items.each do |group_action|
          autoscaling_group_action_list << group_action.id
          autoscaling_group_action_list << group_action.properties.action_status
          autoscaling_group_action_list << group_action.properties.action_type
          autoscaling_group_action_list << group_action.properties.target_replica_count
        end

        puts ui.list(autoscaling_group_action_list, :uneven_columns_across, 4)
      end
    end
  end
end
