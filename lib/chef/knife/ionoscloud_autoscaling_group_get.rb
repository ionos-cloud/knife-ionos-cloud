require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudVmAutoscalingGroupGet < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud vm autoscaling group get (options)'

      option :group_id,
              short: '-G GROUP_ID',
              long: '--group-id GROUP_ID',
              description: 'ID of the VM Autoscaling Group'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Retrieves information about a Ionoscloud VM Autoscaling Group.'
        @required_options = [:group_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        print_autoscaling_group(IonoscloudVmAutoscaling::GroupsApi.new(api_client_vm_autoscaling).autoscaling_groups_find_by_id(config[:group_id]))
      end
    end
  end
end
