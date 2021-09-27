require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudNodepoolUpdate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud nodepool update (options)'

      option :cluster_id,
              short: '-C CLUSTER_ID',
              long: '--cluster-id CLUSTER_ID',
              description: 'ID of the Kubernetes cluster'

      option :nodepool_id,
              short: '-P NODEPOOL_ID',
              long: '--nodepool-id NODEPOOL_ID',
              description: 'ID of the Kubernetes nodepool'

      option :k8s_version,
              short: '-v VERSION',
              long: '--version VERSION',
              description: 'The version for the Kubernetes cluster.'

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
        'Updates information about a Ionoscloud K8s Nodepool.'
        @required_options = [:cluster_id, :nodepool_id, :ionoscloud_username, :ionoscloud_password]
        @updatable_fields = [
          :k8s_version, :node_count, :public_ips, :lans, :maintenance_day, :maintenance_time,
          :min_node_count, :max_node_count, :labels, :annotations,
        ]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        config[:public_ips] = config[:public_ips].split(',') if config[:public_ips] && config[:public_ips].instance_of?(String)
        config[:lans] = config[:lans].split(',') if config[:lans] && config[:lans].instance_of?(String)
        config[:labels] = JSON[config[:labels]] if config[:labels] && config[:labels].instance_of?(String)
        config[:annotations] = JSON[config[:annotations]] if config[:annotations] && config[:annotations].instance_of?(String)

        kubernetes_api = Ionoscloud::KubernetesApi.new(api_client)

        if @updatable_fields.map { |el| config[el] }.any?
          print "#{ui.color('Updating K8s Nodepool...', :magenta)}"

          nodepool = kubernetes_api.k8s_nodepools_find_by_id(config[:cluster_id], config[:nodepool_id])

          new_nodepool = Ionoscloud::KubernetesNodePoolForPut.new(
            properties: Ionoscloud::KubernetesNodePoolPropertiesForPut.new(
              k8s_version: config.key?(:k8s_version) ? config[:k8s_version] : nodepool.properties.k8s_version,
              node_count: config.key?(:node_count) ? config[:node_count] : nodepool.properties.node_count,
              public_ips: config.key?(:public_ips) ? config[:public_ips] : nodepool.properties.public_ips,
              labels: config.key?(:labels) ? config[:labels] : nodepool.properties.labels,
              annotations: config.key?(:annotations) ? config[:annotations] : nodepool.properties.annotations,
              lans: config.key?(:lans) ? config[:lans].map! { |lan| { id: Integer(lan) } } : nodepool.properties.lans,
              maintenance_window: Ionoscloud::KubernetesMaintenanceWindow.new(
                day_of_the_week: config.key?(:maintenance_day) ? config[:maintenance_day] : nodepool.properties.maintenance_window.day_of_the_week,
                time: config.key?(:maintenance_time) ? config[:maintenance_time] : nodepool.properties.maintenance_window.time,
              ),
              auto_scaling: Ionoscloud::KubernetesAutoScaling.new(
                min_node_count: config.key?(:min_node_count) ? config[:min_node_count] : nodepool.properties.auto_scaling.min_node_count,
                max_node_count: config.key?(:max_node_count) ? config[:max_node_count] : nodepool.properties.auto_scaling.max_node_count,
              ),
            ),
          )

          kubernetes_api.k8s_nodepools_put(config[:cluster_id], config[:nodepool_id], new_nodepool)
        else
          ui.warn("Nothing to update, please set one of the attributes #{@updatable_fields}.")
        end

        print_k8s_nodepool(kubernetes_api.k8s_nodepools_find_by_id(config[:cluster_id], config[:nodepool_id]))
      end
    end
  end
end
