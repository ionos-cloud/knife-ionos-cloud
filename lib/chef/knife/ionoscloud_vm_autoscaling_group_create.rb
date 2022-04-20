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

      option :datacenter_id,
              long: '--datacenter-id DATACENTER_ID',
              description: 'VMs for this autoscaling group will be created in this virtual data center.'

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
          :max_replica_count, :min_replica_count, :name, :policy, :replica_configuration, :datacenter_id,
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

        config[:policy] = IonoscloudVmAutoscaling::GroupPolicy.new(
          metric: config[:policy]['metric'],
          range: config[:policy]['range'],
          scale_in_action: IonoscloudVmAutoscaling::GroupPolicyScaleInAction.new(
            amount: config[:policy].dig('scale_in_action', 'amount'),
            amount_type: config[:policy].dig('scale_in_action', 'amount_type'),
            cooldown_period: config[:policy].dig('scale_in_action', 'cooldown_period'),
            termination_policy: config[:policy].dig('scale_in_action', 'termination_policy'),
          ),
          scale_in_threshold: config[:policy]['scale_in_threshold'],
          scale_out_action: IonoscloudVmAutoscaling::GroupPolicyScaleInAction.new(
            amount: config[:policy].dig('scale_out_action', 'amount'),
            amount_type: config[:policy].dig('scale_out_action', 'amount_type'),
            cooldown_period: config[:policy].dig('scale_out_action', 'cooldown_period'),
          ),
          scale_out_threshold: config[:policy]['scale_out_threshold'],
          unit: config[:policy]['unit'],
        )

        config[:replica_configuration] = IonoscloudVmAutoscaling::ReplicaPropertiesPost.new(
          availability_zone: config[:replica_configuration]['availability_zone'],
          cores: config[:replica_configuration]['cores'],
          cpu_family: config[:replica_configuration]['cpu_family'],
          ram: config[:replica_configuration]['ram'],
          nics: config[:replica_configuration].fetch('nics', []).map do |nic|
            IonoscloudVmAutoscaling::ReplicaNic.new(
              lan: Integer(nic['lan']),
              name: nic['name'],
              dhcp: nic['dhcp'],
            )
          end,
          volumes: config[:replica_configuration].fetch('volumes', []).map do |volume|
            IonoscloudVmAutoscaling::ReplicaVolumePost.new(
              image: volume['image'],
              name: volume['name'],
              size: volume['size'],
              ssh_keys: volume['ssh_keys'],
              type: volume['type'],
              user_data: volume['user_data'],
              bus: volume['bus'],
              image_password: volume['image_password'],
            )
          end,
        )

        groups_api = IonoscloudVmAutoscaling::GroupsApi.new(api_client_vm_autoscaling)

        vm_autoscaling_group = IonoscloudVmAutoscaling::Group.new(
          properties: IonoscloudVmAutoscaling::GroupProperties.new(
            max_replica_count: Integer(config[:max_replica_count]),
            min_replica_count: Integer(config[:min_replica_count]),
            target_replica_count: config[:target_replica_count].nil? ? nil : Integer(config[:target_replica_count]),
            name: config[:name],
            policy: config[:policy],
            replica_configuration: config[:replica_configuration],
            datacenter: { id: config[:datacenter_id] },
            location: config[:location],
          ),
        )

        print_autoscaling_group(groups_api.autoscaling_groups_post(vm_autoscaling_group))
      end
    end
  end
end
