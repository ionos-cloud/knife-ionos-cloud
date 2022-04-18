require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudVmAutoscalingGroupCreate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud vm autoscaling group create (options)'

      option :max_replica_count,
              long: '--max-replica-count MAX_REPLICA_COUNT',
              description: 'Maximum replica count value for `targetReplicaCount`. Will be enforced for both automatic and manual changes.'

      option :min_replica_count,
              long: '--min-replica-count MIN_REPLICA_COUNT',
              description: 'Minimum replica count value for `targetReplicaCount`. Will be enforced for both automatic and manual changes.'

      option :target_replica_count,
              long: '--target-replica-count TARGET_REPLICA_COUNT',
              description: 'The target number of VMs in this Group. Depending on the scaling policy, this number will be adjusted automatically. VMs will be created or destroyed automatically in order to adjust the actual number of VMs to this number. If targetReplicaCount is given in the request body then it must be >= minReplicaCount and <= maxReplicaCount.'

      option :name,
              short: '-N NAME',
              long: '--name NAME',
              description: 'The name of the object that will be created.'

      option :policy,
              long: '--policy POLICY',
              description: 'The policy for the policy of autoscaling group.'

      option :replica_configuration,
              long: '--replica-configuration REPLICA_CONFIGURATION',
              description: 'The replica configuration for ionoscloud autoscaling group.'

      option :resource_id,
              long: '--resource-id RESOURCE_ID',
              description: 'The id of the datacenter of the vm Autoscaling Group to create.'

      option :resource_type,
              long: '--resource-type RESOURCE_TYPE',
              description: 'The type of the resource of the vm Autoscaling Group to create.'

      option :location,
              short: '-L LOCATION',
              long: '--location LOCATION',
              description: 'The location for the autoscaling group'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Creates a new vm Autoscaling Group.'
        @required_options = [
          :max_replica_count, :min_replica_count, :name, :policy, :replica_configuration, :resource_id, :resource_type,
          :location, :ionoscloud_username, :ionoscloud_password,
        ]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        print "#{ui.color('Creating VM Autoscaling Group...', :magenta)}"

        config[:policy] = JSON[config[:policy]] if config[:policy] && config[:policy].instance_of?(String)
        config[:replica_configuration] = JSON[config[:replica_configuration]] if config[:replica_configuration] && config[:replica_configuration].instance_of?(String)

        groups_api = IonoscloudVmAutoscaling::GroupsApi.new(api_client_vm_autoscaling)

        vm_autoscaling_group_properties = IonoscloudVmAutoscaling::GroupProperties.new(
          max_replica_count: Integer(config[:max_replica_count]),
          min_replica_count: Integer(config[:min_replica_count]),
          target_replica_count: Integer(config[:target_replica_count]),
          name: config[:name],
          policy: config[:policy],
          replica_configuration: config[:replica_configuration],
          datacenter: IonoscloudVmAutoscaling::Resource.new(
            id: config[:resource_id],
            type: config[:resource_type],
          ),
          location: config[:location],
        )

        vm_autoscaling_group = IonoscloudVmAutoscaling::Group.new()
        vm_autoscaling_group.properties = vm_autoscaling_group_properties

        vm_autoscaling_group = groups_api.autoscaling_groups_post(vm_autoscaling_group)

        print_autoscaling_group(vm_autoscaling_group)
      end
    end
  end
end
