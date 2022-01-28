require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudVmAutoscalingGroupGet < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud vm autoscaling group get (options)'

      option :group_id,
              short: '-G GROUP_ID',
              long: '--group-id GROUP_ID',
              description: 'ID of the vm autoscaling group'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Retrieves information about a Ionoscloud vm Autoscaling Group.'
        @required_options = [:group_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        print_autoscaling_group(IonoscloudAutoscaling::GroupsApi.new(api_client).autoscaling_groups_find_by_id(config[:group_id]))
      end
    end
  end
end
