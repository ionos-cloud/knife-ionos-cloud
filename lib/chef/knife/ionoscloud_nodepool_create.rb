require 'chef/knife/ionoscloud_base'

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

      option :version,
              short: '-v VERSION',
              long: '--version VERSION',
              description: 'The version for the Kubernetes cluster.'

      option :maintenanceday,
              short: '-d MAINTENANCE_DAY',
              long: '--maintenance-day MAINTENANCE_DAY',
              description: 'Day Of the week when to perform the maintenance.'

      option :maintenancetime,
              short: '-t MAINTENANCE_TIME',
              long: '--maintenance-time MAINTENANCE_TIME',
              description: 'Time Of the day when to perform the maintenance.'

      option :nodecount,
              short: '-c NODE_COUNT',
              long: '--node-count NODE_COUNT',
              description: 'The number of worker nodes that the node pool should contain. Min 2, Max: Determined by the resource availability.'

      option :cpufamily,
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

      option :availabilityzone,
              short: '-a AVAILABILITY_ZONE',
              long: '--availability-zone AVAILABILITY_ZONE',
              description: 'The availability zone of the node pool',
              default: 'AUTO'

      option :storagetype,
              long: '--storage-type STORAGE_TYPE',
              description: 'Sets the storage type. [HDD, SSD]',
              default: 'HDD'

      option :storagesize,
              long: '--storage-size STORAGE_SIZE',
              description: 'The total allocated storage capacity of a node.'
    
      option :minnodecount,
              long: '--min-node-count MIN_NODE_COUNT',
              description: 'The minimum number of worker nodes that the managed node group can scale in'

      option :maxnodecount,
              long: '--max-node-count MAX_NODE_COUNT',
              description: 'The maximum number of worker nodes that the managed node pool can scale-out.'
    
      option :lans,
              long: '--lans LAN_ID [LAN_ID]',
              description: 'An array of additional private LANs attached to worker nodes',
              proc: proc { |lans| lans.split(',').map! { |lan| { id: Integer(lan) } } }

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        "Creates a node pool into an existing Kubernetes cluster. "\
        "The Kubernetes cluster must be in state \"ACTIVE\" before creating a node pool.\n\n"\
        "The worker nodes within the node pools will be deployed into an existing data centers."
        @required_options = [
          :datacenter_id, :cluster_id, :name, :version, 
          :nodecount, :cpufamily, :cores, :ram, 
          :availabilityzone, :storagetype, :storagesize,
        ]
      end

      def run
        validate_required_params(@required_options, config)
        $stdout.sync = true

        print "#{ui.color('Creating K8s Nodepool...', :magenta)}"

        kubernetes_api = Ionoscloud::KubernetesApi.new(api_client)

        nodepool_properties = {
          name: config[:name],
          k8sVersion: config[:version],
          datacenterId: config[:datacenter_id],
          nodeCount: config[:nodecount],
          cpuFamily: config[:cpufamily],
          coresCount: config[:cores],
          ramSize: config[:ram],
          availabilityZone: config[:availabilityzone],
          storageType: config[:storagetype],
          storageSize: config[:storagesize],
        }

        if config[:maintenanceday] && config[:maintenancetime]
          nodepool_properties[:maintenanceWindow] = {
            dayOfTheWeek: config[:maintenanceday],
            time: config[:maintenancetime],
          }
        end

        if config[:minnodecount] || config[:maxnodecount]
          nodepool_properties[:autoScaling] = {}
          nodepool_properties[:autoScaling][:minNodeCount] = config[:minnodecount] unless config[:minnodecount].nil?
          nodepool_properties[:autoScaling][:maxNodeCount] = config[:maxnodecount] unless config[:maxnodecount].nil?
        end

        if config[:lans]
          nodepool_properties[:lans] = config[:lans]
        end

        nodepool = kubernetes_api.k8s_nodepools_post(config[:cluster_id], { properties: nodepool_properties })

        auto_scaling = "Min node count: #{nodepool.properties.auto_scaling.min_node_count}, Max node count:#{nodepool.properties.auto_scaling.max_node_count}"
        maintenance_window = "#{nodepool.properties.maintenance_window.day_of_the_week}, #{nodepool.properties.maintenance_window.time}"

        puts "\n"
        puts "#{ui.color('ID', :cyan)}: #{nodepool.id}"
        puts "#{ui.color('Name', :cyan)}: #{nodepool.properties.name}"
        puts "#{ui.color('K8s Version', :cyan)}: #{nodepool.properties.k8s_version}"
        puts "#{ui.color('Datacenter ID', :cyan)}: #{nodepool.properties.datacenter_id}"
        puts "#{ui.color('Node Count', :cyan)}: #{nodepool.properties.node_count}"
        puts "#{ui.color('CPU Family', :cyan)}: #{nodepool.properties.cpu_family}"
        puts "#{ui.color('Cores Count', :cyan)}: #{nodepool.properties.cores_count}"
        puts "#{ui.color('RAM', :cyan)}: #{nodepool.properties.ram_size}"
        puts "#{ui.color('Storage Type', :cyan)}: #{nodepool.properties.storage_type}"
        puts "#{ui.color('Storage Size', :cyan)}: #{nodepool.properties.storage_size}"
        puts "#{ui.color('Availability Zone', :cyan)}: #{nodepool.properties.availability_zone}"
        puts "#{ui.color('Auto Scaling', :cyan)}: #{auto_scaling}"
        puts "#{ui.color('Maintenance Window', :cyan)}: #{maintenance_window}"
        puts "#{ui.color('State', :cyan)}: #{nodepool.metadata.state}"
        puts 'done'
      end
    end
  end
end
