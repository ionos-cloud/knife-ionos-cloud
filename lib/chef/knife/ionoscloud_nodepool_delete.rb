require 'chef/knife/ionoscloud_base'

class Chef
  class Knife
    class IonoscloudNodepoolDelete < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud nodepool delete NODEPOOL_ID [NODEPOOL_ID] (options)'

      option :cluster_id,
              short: '-C CLUSTER_ID',
              long: '--cluster-id CLUSTER_ID',
              description: 'The ID of the K8s Cluster'

      def run
        $stdout.sync = true

        kubernetes_api = Ionoscloud::KubernetesApi.new(api_client)

        @name_args.each do |nodepool_id|
          begin
            nodepool = kubernetes_api.k8s_nodepools_find_by_id(config[:cluster_id], nodepool_id)
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("K8s Nodepool ID #{nodepool_id} not found. Skipping.")
            next
          end

          msg_pair('ID', nodepool.id)
          msg_pair('Name', nodepool.properties.name)
          msg_pair('K8s Version', nodepool.properties.k8s_version)
          msg_pair('Datacenter ID', nodepool.properties.datacenter_id)
          msg_pair('Node Count', nodepool.properties.node_count)
          msg_pair('State', nodepool.metadata.state)

          puts "\n"

          begin
            confirm('Do you really want to delete this K8s Nodepool')
          rescue SystemExit => exc
            next
          end

          kubernetes_api.k8s_nodepools_delete(config[:cluster_id], nodepool.id)
          ui.warn("Deleted K8s Nodepool #{nodepool.id}.")
        end
      end
    end
  end
end
