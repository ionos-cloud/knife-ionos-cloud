require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudVmAutoscalingGroupServerList < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud vm autoscaling group server list'

      option :group_id,
              short: '-G GROUP_ID',
              long: '--group-id GROUP_ID',
              description: 'ID of the VM Autoscaling Group'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'retrieves a list of all VM Autoscaling Group server.'
        @required_options = [:group_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        autoscaling_group_server_list = [
          ui.color('ID', :bold),
          ui.color('TYPE', :bold),
        ]

        groups_api = IonoscloudVmAutoscaling::GroupsApi.new(api_client_vm_autoscaling)

        groups_api.autoscaling_groups_servers_get(config[:group_id]).items.each do |group_server|
          autoscaling_group_server_list << group_server.id
          autoscaling_group_server_list << group_server.type
        end

        puts ui.list(autoscaling_group_server_list, :uneven_columns_across, 2)
      end
    end
  end
end
