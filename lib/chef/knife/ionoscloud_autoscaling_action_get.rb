require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudAutoscalingActionGet < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud vm autoscailing action get (options)'

      option :action_id,
              short: '-A ACTION_ID',
              long: '--action-id ACTION_ID',
              description: 'ID of the vm autoscailing action'
              
      option :group_id,
              short: '-G GROUP_ID',
              long: '--group-id GROUP_ID',
              description: 'ID of the vm autoscailing group'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Retrieves information about a Ionoscloud vm Autoscailing Action.'
        @required_options = [:action_id, :group_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        print_autoscailing_action(
          IonoscloudAutoscaling::GroupsApi.new(api_client).autoscaling_groups_actions_find_by_id(
            config[:action_id], 
            config[:group_id],
            )
          )
      end
    end
  end
end
