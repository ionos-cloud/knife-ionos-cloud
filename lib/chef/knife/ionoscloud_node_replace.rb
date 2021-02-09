require 'chef/knife/ionoscloud_base'

class Chef
  class Knife
    class IonoscloudNodeReplace < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud node replace NODE_ID [NODE_ID] (options)'

      option :cluster_id,
              short: '-C CLUSTER_ID',
              long: '--cluster-id CLUSTER_ID',
              description: 'The ID of the K8s Cluster'


      option :nodepool_id,
              short: '-P NODEPOOL_ID',
              long: '--nodepool-id NODEPOOL_ID',
              description: 'The ID of the K8s Nodepool'

      def run
        $stdout.sync = true

        kubernetes_api = Ionoscloud::KubernetesApi.new(api_client)

        @name_args.each do |node_id|
          begin
            _, _, headers = kubernetes_api.k8s_nodepools_nodes_replace_post_with_http_info(config[:cluster_id], config[:nodepool_id], node_id)
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("K8s Node ID #{node_id} not found. Skipping.")
            next
          end

          ui.warn("Recreated K8s Node #{node.id}.")
        end
      end
    end
  end
end
