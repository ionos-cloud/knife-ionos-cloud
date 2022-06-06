require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudNodepoolDelete < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud nodepool delete NODEPOOL_ID [NODEPOOL_ID] (options)'

      option :cluster_id,
              short: '-C CLUSTER_ID',
              long: '--cluster-id CLUSTER_ID',
              description: 'The ID of the K8s Cluster'

      def initialize(args = [])
        super(args)
        @description =
        'Deletes a node pool within an existing Kubernetes cluster.'
        @directory = 'kubernetes'
        @required_options = [:cluster_id]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        kubernetes_api = Ionoscloud::KubernetesApi.new(api_client)

        @name_args.each do |nodepool_id|
          begin
            nodepool = kubernetes_api.k8s_nodepools_find_by_id(config[:cluster_id], nodepool_id)
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("K8s Nodepool ID #{nodepool_id} not found. Skipping.")
            next
          end

          print_k8s_nodepool(nodepool)
          puts "\n"

          begin
            confirm('Do you really want to delete this K8s Nodepool')
          rescue SystemExit
            next
          end

          kubernetes_api.k8s_nodepools_delete(config[:cluster_id], nodepool.id)
          ui.warn("Deleted K8s Nodepool #{nodepool.id}.")
        end
      end
    end
  end
end
