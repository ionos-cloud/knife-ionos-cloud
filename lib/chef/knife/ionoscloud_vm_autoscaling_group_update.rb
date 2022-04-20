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

        config[:policy] = JSON[config[:policy]] if config[:policy] && config[:policy].instance_of?(String)

        if @updatable_fields.map { |el| config[el] }.any?
          print "#{ui.color('Updating the VM Autoscaling Group...', :magenta)}"

          existing_group = groups_api.autoscaling_groups_find_by_id(config[:group_id])

          if config[:replica_configuration].nil?
            replica_configuration = IonoscloudVmAutoscaling::ReplicaProperties.new(
              availability_zone: existing_group.properties.replica_configuration.availability_zone,
              cores: existing_group.properties.replica_configuration.cores,
              cpu_family: existing_group.properties.replica_configuration.cpu_family,
              ram: existing_group.properties.replica_configuration.ram,
              nics: existing_group.properties.replica_configuration.nics,
            )
          else
            config[:replica_configuration] = JSON[config[:replica_configuration]] if config[:replica_configuration] && config[:replica_configuration].instance_of?(String)

            if config[:replica_configuration]['nics'].nil?
              nics = existing_group.properties.replica_configuration.nics
            else
              nics = config[:replica_configuration].fetch('nics', []).map do |nic|
                IonoscloudVmAutoscaling::ReplicaNic.new(
                  lan: Integer(nic['lan']),
                  name: nic['name'],
                  dhcp: nic['dhcp'],
                )
              end
            end

            replica_configuration = IonoscloudVmAutoscaling::ReplicaProperties.new(
              availability_zone: ternary(config[:replica_configuration]['availability_zone'], existing_group.properties.replica_configuration.availability_zone),
              cores: ternary(config[:replica_configuration]['cores'], existing_group.properties.replica_configuration.cores),
              cpu_family: ternary(config[:replica_configuration]['cpu_family'], existing_group.properties.replica_configuration.cpu_family),
              ram: ternary(config[:replica_configuration]['ram'], existing_group.properties.replica_configuration.ram),
              nics: nics,
            )
          end

          if config[:policy].nil?
            policy = existing_group.properties.policy
          else
            config[:policy] = JSON[config[:policy]] if config[:policy] && config[:policy].instance_of?(String)
            policy = IonoscloudVmAutoscaling::GroupPolicy.new(
              metric: ternary(config[:policy]['metric'], existing_group.properties.policy.metric),
              range: ternary(config[:policy]['range'], existing_group.properties.policy.range),
              scale_in_action: IonoscloudVmAutoscaling::GroupPolicyScaleInAction.new(
                amount: ternary(config[:policy].dig('scale_in_action', 'amount'), existing_group.properties.policy.scale_in_action.amount),
                amount_type: ternary(config[:policy].dig('scale_in_action', 'amount_type'), existing_group.properties.policy.scale_in_action.amount_type),
                cooldown_period: ternary(config[:policy].dig('scale_in_action', 'cooldown_period'), existing_group.properties.policy.scale_in_action.cooldown_period),
                termination_policy: ternary(config[:policy].dig('scale_in_action', 'termination_policy'), existing_group.properties.policy.scale_in_action.termination_policy),
              ),
              scale_in_threshold: ternary(config[:policy]['scale_in_threshold'], existing_group.properties.policy.scale_in_threshold),
              scale_out_action: IonoscloudVmAutoscaling::GroupPolicyScaleInAction.new(
                amount: ternary(config[:policy].dig('scale_out_action', 'amount'), existing_group.properties.policy.scale_out_action.amount),
                amount_type: ternary(config[:policy].dig('scale_out_action', 'amount_type'), existing_group.properties.policy.scale_out_action.amount_type),
                cooldown_period: ternary(config[:policy].dig('scale_out_action', 'cooldown_period'), existing_group.properties.policy.scale_out_action.cooldown_period),
              ),
              scale_out_threshold: ternary(config[:policy]['scale_out_threshold'], existing_group.properties.policy.scale_out_threshold),
              unit: ternary(config[:policy]['unit'], existing_group.properties.policy.unit),
            )
          end

          vm_autoscaling_group_update = IonoscloudVmAutoscaling::GroupUpdate.new(
            properties: IonoscloudVmAutoscaling::GroupUpdatableProperties.new(
              min_replica_count: Integer(ternary(config[:min_replica_count], existing_group.properties.min_replica_count)),
              max_replica_count: Integer(ternary(config[:max_replica_count], existing_group.properties.max_replica_count)),
              target_replica_count: Integer(ternary(config[:target_replica_count], existing_group.properties.target_replica_count)),
              name: ternary(config[:name], existing_group.properties.name),
              policy: policy,
              replica_configuration: replica_configuration,
              datacenter: { id: existing_group.properties.datacenter.id },
            ),
          )

          groups_api.autoscaling_groups_put_with_http_info(config[:group_id], vm_autoscaling_group_update)
        else
          ui.warn("Nothing to update, please set one of the attributes #{@updatable_fields}.")
        end

        print_autoscaling_group(groups_api.autoscaling_groups_find_by_id(config[:group_id]))
      end
    end
  end
end
