require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudVmAutoscalingGroupUpdate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud vm autoscaling group update (options)'

      option :group_id,
              short: '-G GROUP_ID',
              long: '--group-id GROUP_ID',
              description: 'ID of the VM Autoscaling Group'

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
              description: 'The type of object that has been created.'
              
      option :policy,
              long: '--policy POLICY',
              description: 'The policy for the VM Autoscaling Group.'

      option :replica_configuration,
              long: '--replica-configuration REPLICA_CONFIGURATION',
              description: 'The replica configuration for ionoscloud autoscaling group.'
        
      option :resource_id,
              long: '--resource-id RESOURCE_ID',
              description: 'The id of the datacenter of the VM Autoscaling Group to create.'

      option :resource_type,
              long: '--resource-type RESOURCE_TYPE',
              description: 'The type of the resource of the VM Autoscaling Group to create.'


      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Updates information about a Ionoscloud Dbaas Cluster.'
        @required_options = [:group_id, :ionoscloud_username, :ionoscloud_password]
        @updatable_fields = [:max_replica_count, :min_replica_count, :target_replica_count, :name, :policy, :replica_configuration, :resource_id, :resource_type]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        groups_api = IonoscloudVmAutoscaling::GroupsApi.new(api_client_vm_autoscaling)

        config[:replica_configuration] = JSON[config[:replica_configuration]] if config[:replica_configuration] && config[:replica_configuration].instance_of?(String)
        config[:policy] = JSON[config[:policy]] if config[:policy] && config[:policy].instance_of?(String)

        if @updatable_fields.map { |el| config[el] }.any?
          print "#{ui.color('Updating the VM Autoscaling Group...', :magenta)}"
          
          group_properties = IonoscloudVmAutoscaling::GroupUpdatableProperties.new(
            max_replica_count: (config[:max_replica_count].nil? ? nil : Integer(config[:max_replica_count])),
            min_replica_count: (config[:min_replica_count].nil? ? nil : Integer(config[:min_replica_count])),
            target_replica_count: (config[:target_replica_count].nil? ? nil : Integer(config[:target_replica_count])),
            name: config[:name],
            policy: (config[:policy].nil? ? nil : config[:policy]),
            replica_configuration: (config[:replica_configuration].nil? ? nil : config[:replica_configuration]),
            datacenter: (config[:resource_id] && config[:resource_type]) ? IonoscloudVmAutoscaling::Resource.new(
              resource_id: config[:resource_id],
              resource_type: config[:resource_type],
            ) : nil,
          )

          vm_autoscaling_group_update = IonoscloudVmAutoscaling::GroupUpdate.new()
          vm_autoscaling_group_update.properties = vm_autoscaling_group_properties

          groups_api.autoscaling_groups_put_with_http_info(config[:group_id], vm_autoscaling_group_update)
        else
          ui.warn("Nothing to update, please set one of the attributes #{@updatable_fields}.")
        end

        print_autoscaling_group(groups_api.autoscaling_groups_find_by_id(config[:group_id]))
      end
    end
  end
end