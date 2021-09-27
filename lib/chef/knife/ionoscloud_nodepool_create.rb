require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudNodepoolCreate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud nodepool create (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'ID of the virtual datacenter'

      option :cluster_id,
              short: '-C CLUSTER_ID',
              long: '--cluster-id CLUSTER_ID',
              description: 'ID of the Kubernetes cluster'

      option :name,
              short: '-n NAME',
              long: '--name NAME',
              description: 'Name of the Kubernetes node pool'

      option :k8s_version,
              short: '-v VERSION',
              long: '--version VERSION',
              description: 'The version for the Kubernetes Nodepool.'

      option :maintenance_day,
              long: '--maintenance-day MAINTENANCE_DAY',
              description: 'Day Of the week when to perform the maintenance.'

      option :maintenance_time,
              short: '-t MAINTENANCE_TIME',
              long: '--maintenance-time MAINTENANCE_TIME',
              description: 'Time Of the day when to perform the maintenance.'

      option :node_count,
              short: '-c NODE_COUNT',
              long: '--node-count NODE_COUNT',
              description: 'The number of worker nodes that the node pool should contain. Min 2, Max: Determined by the resource availability.'

      option :cpu_family,
              short: '-f CPU_FAMILY',
              long: '--cpu-family CPU_FAMILY',
              description: 'Sets the CPU type. [AMD_OPTERON, INTEL_XEON, INTEL_SKYLAKE]',
              default: 'INTEL_SKYLAKE'

      option :cores,
              long: '--cores CORES',
              description: 'The total number of cores for the node.'

      option :ram,
              short: '-r RAM',
              long: '--ram RAM',
              description: 'The amount of RAM in MB'

      option :availability_zone,
              short: '-a AVAILABILITY_ZONE',
              long: '--availability-zone AVAILABILITY_ZONE',
              description: 'The availability zone of the node pool',
              default: 'AUTO'

      option :storage_type,
              long: '--storage-type STORAGE_TYPE',
              description: 'Sets the storage type. [HDD, SSD]',
              default: 'HDD'

      option :storage_size,
              long: '--storage-size STORAGE_SIZE',
              description: 'The total allocated storage capacity of a node.'

      option :min_node_count,
              long: '--min-node-count MIN_NODE_COUNT',
              description: 'The minimum number of worker nodes that the managed node group can scale in'

      option :max_node_count,
              long: '--max-node-count MAX_NODE_COUNT',
              description: 'The maximum number of worker nodes that the managed node pool can scale-out.'

      option :lans,
              long: '--lans LAN_ID [LAN_ID]',
              description: 'An array of additional private LANs attached to worker nodes'

      option :public_ips,
              long: '--ips PUBLIC_IP [PUBLIC_IP]',
              description: 'Optional array of reserved public IP addresses to be used by the nodes. '\
              'IPs must be from same location as the data center used for the node pool. The array '\
              'must contain one extra IP than maximum number of nodes could be. (nodeCount+1 if fixed '\
              'node amount or maxNodeCount+1 if auto scaling is used) The extra provided IP Will be used during rebuilding of nodes.'

      option :labels,
              long: '--labels LABEL [LABEL]',
              description: 'map of labels attached to node pool'

      option :annotations,
              long: '--annotations ANNOTATION [ANNOTATION]',
              description: 'map of annotations attached to node pool'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        "Creates a node pool into an existing Kubernetes cluster. "\
        "The Kubernetes cluster must be in state \"ACTIVE\" before creating a node pool.\n\n"\
        "The worker nodes within the node pools will be deployed into an existing data centers."
        @required_options = [
          :datacenter_id, :cluster_id, :name, :k8s_version, :node_count, :cpu_family, :cores, :ram,
          :availability_zone, :storage_type, :storage_size, :ionoscloud_username, :ionoscloud_password,
        ]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        print "#{ui.color('Creating K8s Nodepool...', :magenta)}"

        kubernetes_api = Ionoscloud::KubernetesApi.new(api_client)

        config[:public_ips] = config[:public_ips].split(',') if config[:public_ips] && config[:public_ips].instance_of?(String)
        config[:lans] = config[:lans].split(',') if config[:lans] && config[:lans].instance_of?(String)
        config[:labels] = JSON[config[:labels]] if config[:labels] && config[:labels].instance_of?(String)
        config[:annotations] = JSON[config[:annotations]] if config[:annotations] && config[:annotations].instance_of?(String)

        nodepool_properties = {
          name: config[:name],
          k8s_version: config[:k8s_version],
          datacenter_id: config[:datacenter_id],
          node_count: config[:node_count],
          cpu_family: config[:cpu_family],
          cores_count: config[:cores],
          ram_size: config[:ram],
          availability_zone: config[:availability_zone],
          storage_type: config[:storage_type],
          storage_size: config[:storage_size],
          public_ips: config[:public_ips],
          labels: config[:labels],
          annotations: config[:annotations],
          lans: config.key?(:lans) ? config[:lans].map! { |lan| { id: Integer(lan) } } : nil,
          auto_scaling: Ionoscloud::KubernetesAutoScaling.new(
            min_node_count: config[:min_node_count],
            max_node_count: config[:max_node_count],
          ),
          maintenance_window: (config.key?(:maintenance_day) || config.key?(:maintenance_time)) ? Ionoscloud::KubernetesMaintenanceWindow.new(
            day_of_the_week: config[:maintenance_day],
            time: config[:maintenance_time],
          ) : nil,
        }

        print_k8s_nodepool(
          kubernetes_api.k8s_nodepools_post(
            config[:cluster_id],
            Ionoscloud::KubernetesNodePoolForPost.new(
              properties: Ionoscloud::KubernetesNodePoolPropertiesForPost.new(
                **nodepool_properties,
              ),
            ),
          ),
        )
      end
    end
  end
end
