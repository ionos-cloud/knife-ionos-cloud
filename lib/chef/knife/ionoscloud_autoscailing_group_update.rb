require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudAutoscailingGroupUpdate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud vm autoscailing group update (options)'

      option :group_id,
              short: '-G GROUP_ID',
              long: '--group-id GROUP_ID',
              description: 'ID of the vm autoscailing group'

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
              description: 'The policy for the vm autoscailing group.'

      option :replica_configuration,
              long: '--replica-configuration REPLICA_CONFIGURATION',
              description: 'The replica configuration for ionoscloud autoscailing group.'
        
      option :resource_id,
              long: '--resource-id RESOURCE_ID',
              description: 'The id of the datacenter of the vm Autoscailing Group to create.'

      option :resource_type,
              long: '--resource-type RESOURCE_TYPE',
              description: 'The type of the resource of the vm Autoscailing Group to create.'


      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Updates information about a Ionoscloud Dbaas Cluster.'
        @required_options = [:group_id, :ionoscloud_username, :ionoscloud_password]# todo asta nu stiu inca
        @updatable_fields = [:max_replica_count, :min_replica_count, :target_replica_count, :name, :policy, :replica_configuration, :resource_id, :resource_type]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        gropus_api = IonoscloudAutoscaling::GroupsApi.new(api_client)

        if @updatable_fields.map { |el| config[el] }.any?
          print "#{ui.color('Updating the vm Autoscailing Group...', :magenta)}"

          configuration[:policy] = IonoscloudAutoscaling::GroupPolicy.new(
            metric: policyp['metric'], # e enum
            range: policy['range'],
            scale_in_action: IonoscloudAutoscaling::GroupPolicyScaleInAction.new(
              amount: (config[:amount].nil? ? nil : Float(config[:amount])),
              amount_type: policy['amount_type'], # e enum
              cooldown_period: policy['cooldown_period'],
              termination_policy: policy['cooldown_period'], # e enum
            ),
            scale_in_threshold: policy['scale_in_threshold'],
            scale_out_action: IonoscloudAutoscaling::GroupPolicyScaleOutAction.new(
              amount: F(config[:amount].nil? ? nil : Float(config[:amount])),
              amount_type: policy['amount_type'], # e enum
              cooldown_period: policy['cooldown_period'],
            ),
            scale_out_threshold: policy['scale_out_threshold'],
            unit: policy['unit'], # e enum
          )
  
          nics = replica_configuration['nics'].map do |nic|
            IonoscloudAutoscaling::ReplicaNic.new(
              lan: (config[:lan].nil? ? nil : Integer(config[:lan])),
              name: nic['name'],
              dhcp: Boolean(nic['dhcp']),
            )
          end
  
          volumes = eplica_configuration['volumes'].map do |volume|
            IonoscloudAutoscaling::ReplicaVolumePost.new(
              image: volume['image'],
              name: volume['name'],
              size: (config[:size].nil? ? nil : Integer(config[:size])),
              ssh_keys: volume['ssh_keys'],
              type: volume['type'], # e enum
              user_data: volume['user_data'],
              image_password: volume['image_password'],
            )
          end
  
          config[:replica_configuration] = IonoscloudAutoscaling::ReplicaPropertiesPost.new(
            availability_zone: replica_configuration['availability_zone'], # e enum
            cores: (config[:cores].nil? ? nil : Integer(config[:cores])),
            cpu_family: replica_configuration['cpu_family'],
            nics: nics,
            ram: (config[:ram].nil? ? nil : Integer(config[:ram])),
            volumes: volumes,
          )
          
          group_properties = IonoscloudAutoscaling::GroupUpdatableProperties.new(
            max_replica_count: (config[:max_replica_count].nil? ? nil : Integer(config[:max_replica_count])),
            min_replica_count: (config[:min_replica_count].nil? ? nil : Integer(config[:min_replica_count])),
            target_replica_count: (config[:target_replica_count].nil? ? nil : Integer(config[:target_replica_count])),
            name: config[:name],
            policy: configuration[:policy],
            replica_configuration: config[:replica_configuration],
            datacenter: (config[:resource_id] && config[:resource_type]) ? IonoscloudAutoscaling::Resource.new(
              resource_id: config[:resource_id],
              resource_type: config[:resource_type],
            ) : nil,
          )

          group_update = IonoscloudAutoscaling::GroupUpdate.new()
          group_update.properties = group_properties

          cluster, _, headers  = gropus_api.autoscaling_groups_put_with_http_info(config[:group_id], group_update)

          dot = ui.color('.', :magenta)
        else
          ui.warn("Nothing to update, please set one of the attributes #{@updatable_fields}.")
        end

        print_autoscailing_group(gropus_api.autoscaling_groups_find_by_id(config[:group_id]))
      end
    end
  end
end