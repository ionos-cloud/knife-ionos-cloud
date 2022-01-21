require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudAutoscalingActionsList < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud vm autoscailing group actions list'

      option :group_id,
              short: '-G GROUP_ID',
              long: '--group-id GROUP_ID',
              description: 'ID of the vm autoscailing group'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'retrieves a list of all vm autoscailing group actions.'
        @required_options = [:group_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        autoscailing_group_action_list = [
          ui.color('ID', :bold),
          ui.color('Type', :bold),
        ]

        opts = { depth: 1 }
        groups_api = IonoscloudAutoscaling::GroupsApi.new(api_client)

        groups_api.autoscaling_groups_actions_get(config[:group_id], opts).items.each do |group_action|
          autoscailing_group_action_list << group_action.id
          autoscailing_group_action_list << group_action.type
        end

        puts ui.list(autoscailing_group_action_list, :uneven_columns_across, 2)
      end
    end
  end
end