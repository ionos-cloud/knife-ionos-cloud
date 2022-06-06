require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudNodepoolLanRemove < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud nodepool lan remove LAN_ID [LAN_ID] (options)'

      option :cluster_id,
              short: '-C CLUSTER_ID',
              long: '--cluster-id CLUSTER_ID',
              description: 'ID of the Kubernetes cluster'

      option :nodepool_id,
              short: '-N NODEPOOL_ID',
              long: '--nodepool NODEPOOL_ID',
              description: 'The ID of the K8s Nodepool'

      def initialize(args = [])
        super(args)
        @description =
        'Adds or updates a LAN within a Nodepool.'
        @directory = 'kubernetes'
        @required_options = [:cluster_id, :nodepool_id]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        kubernetes_api = Ionoscloud::KubernetesApi.new(api_client)

        begin
          nodepool = kubernetes_api.k8s_nodepools_find_by_id(config[:cluster_id], config[:nodepool_id])
        rescue Ionoscloud::ApiError => err
          raise err unless err.code == 404
          ui.error("Nodepool ID #{config[:nodepool_id]} not found.")
          exit(1)
        end

        existing = nodepool.properties.lans.select { |lan| @name_args.map { |id| Integer(id) }.include? lan.id }

        if existing.length > 0
          new_nodepool = Ionoscloud::KubernetesNodePool.new(
            properties: Ionoscloud::KubernetesNodePoolPropertiesForPut.new(
              node_count: nodepool.properties.node_count,
              k8s_version: nodepool.properties.k8s_version,
              maintenance_window: nodepool.properties.maintenance_window,
              auto_scaling: nodepool.properties.auto_scaling,
              public_ips: nodepool.properties.public_ips,
              lans: nodepool.properties.lans,
            ),
          )
          new_nodepool.properties.lans.delete_if { |lan| @name_args.map { |id| Integer(id) }.include? lan.id }

          nodepool = kubernetes_api.k8s_nodepools_put(
            config[:cluster_id], config[:nodepool_id], new_nodepool,
          )

          ui.info("Removing Lans #{@name_args} from the Nodepoool.")
        else
          ui.info("None of the specified Lan IDs (#{@name_args}) are present on the Nodepoool.")
        end

        print_k8s_nodepool(nodepool)
      end
    end
  end
end
