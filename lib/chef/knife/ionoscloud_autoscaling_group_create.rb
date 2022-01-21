require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudAutoscalingGroupCreate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud vm autoscailing group create (options)'

      # option :type,
      #         short: '-T TYPE',
      #         long: '--type TYPE',
      #         description: 'The type of object that has been created.'

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
              description: 'The policy for the policy of autoscailing group.'

      option :replica_configuration,
              long: '--replica-configuration REPLICA_CONFIGURATION',
              description: 'The replica configuration for ionoscloud autoscailing group.'

      option :resource_id,
              long: '--resource-id RESOURCE_ID',
              description: 'The id of the datacenter of the vm Autoscailing Group to create.'

      option :resource_type,
              long: '--resource-type RESOURCE_TYPE',
              description: 'The type of the resource of the vm Autoscailing Group to create.'

      option :location,
              short: '-L LOCATION',
              long: '--location LOCATION',
              description: 'The location for the autoscailing group'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Creates a new vm Autoscailing Group.'
        @required_options = [
          :max_replica_count, :min_replica_count, :target_replica_count, :name, :policy, :replica_configuration, :resource_id, :resource_type,
          :location, :ionoscloud_username, :ionoscloud_password,
        ] # todo eu le-am pus pe toate aici, dar nu stiu care sunt required si care nu
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        print "#{ui.color('Creating vm Autoscailing Group...', :magenta)}"

        policy = JSON[config[:policy]] if config[:policy] && config[:policy].instance_of?(String)
        # print('HJASHJDSHJAASJHKG AAAAAAAAAAAAAA')
        # print(policy)
        replica_configuration = JSON[config[:replica_configuration]] if config[:replica_configuration] && config[:replica_configuration].instance_of?(String)

        config[:policy] = IonoscloudAutoscaling::GroupPolicy.new(
          metric: policy['metric'], # e enum
          range: policy['range'],
          scale_in_action: IonoscloudAutoscaling::GroupPolicyScaleInAction.new(
            amount: Float(policy['amount']),
            amount_type: policy['amount_type'], # e enum
            cooldown_period: policy['cooldown_period'],
            termination_policy: policy['cooldown_period'], # e enum
          ),
          scale_in_threshold: policy['scale_in_threshold'],
          scale_out_action: IonoscloudAutoscaling::GroupPolicyScaleOutAction.new(
            amount: Float(policy['amount']),
            amount_type: policy['amount_type'], # e enum
            cooldown_period: policy['cooldown_period'],
          ),
          scale_out_threshold: policy['scale_out_threshold'],
          unit: policy['unit'], # e enum
        )

        nics = replica_configuration['nics'].map do |nic|
          IonoscloudAutoscaling::ReplicaNic.new(
            lan: Integer(nic['lan']),
            name: nic['name'],
            dhcp: Boolean(nic['dhcp']),
          )
        end

        volumes = eplica_configuration['volumes'].map do |volume|
          IonoscloudAutoscaling::ReplicaVolumePost.new(
            image: volume['image'],
            name: volume['name'],
            size: Integer(volume['size']),
            ssh_keys: volume['ssh_keys'],
            type: volume['type'], # e enum
            user_data: volume['user_data'],
            image_password: volume['image_password'],
          )
        end

        config[:replica_configuration] = IonoscloudAutoscaling::ReplicaPropertiesPost.new(
          availability_zone: replica_configuration['availability_zone'], # e enum
          cores: Integer(eplica_configuration['cores']),
          cpu_family: replica_configuration['cpu_family'],
          nics: nics,
          ram: Integer(replica_configuration['ram']),
          volumes: volumes,
        )

        groups_api = IonoscloudAutoscaling::GroupsApi.new(api_client)

        group_properties = IonoscloudAutoscaling::GroupProperties.new(
          max_replica_count: Integer(config[:max_replica_count]),
          min_replica_count: Integer(config[:min_replica_count]),
          target_replica_count: Integer(config[:target_replica_count]),
          name: config[:name],
          policy: configuration[:policy],
          replica_configuration: config[:replica_configuration],
          datacenter: IonoscloudAutoscaling::Resource.new(
            id: config[:resource_id],
            type: config[:resource_type],
          ),
          location: config[:location],
        )

        group = IonoscloudAutoscaling::Group.new()
        group.properties = group_properties
        # group.type = config[:type]

        group, _, headers  = groups_api.autoscaling_groups_post_with_http_info(group)

        print_autoscailing_group(group)
      end
    end
  end
end