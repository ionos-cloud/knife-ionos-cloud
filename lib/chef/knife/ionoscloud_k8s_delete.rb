require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudK8sDelete < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud k8s delete CLUSTER_ID [CLUSTER_ID]'

      def initialize(args = [])
        super(args)
        @description =
        'Deletes a Kubernetes cluster. The cluster cannot contain any node pools when deleting.'
        @directory = 'kubernetes'
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        kubernetes_api = Ionoscloud::KubernetesApi.new(api_client)

        @name_args.each do |cluster_id|
          begin
            cluster = kubernetes_api.k8s_find_by_cluster_id(cluster_id, { depth: 2 })
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("K8s Cluster ID #{cluster_id} not found. Skipping.")
            next
          end

          unless ['ACTIVE', 'TERMINATED'].include? cluster.metadata.state
            ui.error(
              "K8s Cluster #{cluster_id} state must be one of ['ACTIVE', 'TERMINATED'], "\
              "actual state is '#{cluster.metadata.state}'. Skipping.",
            )
            next
          end

          if cluster.entities.nodepools.items.length > 0
            ui.error("K8s Cluster ID #{cluster_id} has existing Nodepools. Skipping.")
            next
          end

          print_k8s_cluster(cluster)
          puts "\n"

          begin
            confirm('Do you really want to delete this K8s Cluster')
          rescue SystemExit
            next
          end

          _, _, headers = kubernetes_api.k8s_delete_with_http_info(cluster.id)
          ui.warn("Deleted K8s Cluster #{cluster.id}. Request ID: #{get_request_id headers}")
        end
      end
    end
  end
end
