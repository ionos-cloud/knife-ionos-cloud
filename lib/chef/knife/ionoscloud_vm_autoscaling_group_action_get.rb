require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudVmAutoscalingGroupActionGet < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud vm autoscaling group action get (options)'

      option :action_id,
              short: '-A ACTION_ID',
              long: '--action-id ACTION_ID',
              description: 'ID of the vm autoscaling action'

      option :group_id,
              short: '-G GROUP_ID',
              long: '--group-id GROUP_ID',
              description: 'ID of the vm autoscaling group'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Retrieves information about a Ionoscloud VM Autoscaling Action.'
        @required_options = [:action_id, :group_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        print_autoscaling_action(IonoscloudVmAutoscaling::GroupsApi.new(api_client_vm_autoscaling).autoscaling_groups_actions_find_by_id(
                                   config[:action_id],
            config[:group_id],
          ),
        )
      end
    end
  end
end
