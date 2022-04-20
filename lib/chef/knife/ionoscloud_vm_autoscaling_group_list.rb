require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudVmAutoscalingGroupList < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud vm autoscaling group list'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'retrieves a list of all vm Autoscaling Groups.'
        @required_options = [:ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        autoscaling_group_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Min Replicas', :bold),
          ui.color('Max Replicas', :bold),
          ui.color('Target Replicas', :bold),
          ui.color('Datacenter ID', :bold),
          ui.color('Location', :bold),
        ]

        groups_api = IonoscloudVmAutoscaling::GroupsApi.new(api_client_vm_autoscaling)

        groups_api.autoscaling_groups_get(depth: 1).items.each do |group|
          autoscaling_group_list << group.id
          autoscaling_group_list << group.properties.name
          autoscaling_group_list << group.properties.min_replica_count
          autoscaling_group_list << group.properties.max_replica_count
          autoscaling_group_list << group.properties.target_replica_count
          autoscaling_group_list << group.properties.datacenter.id
          autoscaling_group_list << group.properties.location
        end

        puts ui.list(autoscaling_group_list, :uneven_columns_across, 7)
      end
    end
  end
end
