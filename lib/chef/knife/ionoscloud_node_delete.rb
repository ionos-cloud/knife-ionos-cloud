require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudNodeDelete < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud node delete NODE_ID [NODE_ID] (options)'

      option :cluster_id,
              short: '-C CLUSTER_ID',
              long: '--cluster-id CLUSTER_ID',
              description: 'The ID of the K8s Cluster'


      option :nodepool_id,
              short: '-P NODEPOOL_ID',
              long: '--nodepool-id NODEPOOL_ID',
              description: 'The ID of the K8s Nodepool'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Delete a single Kubernetes Node.'
        @required_options = [:cluster_id, :nodepool_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        kubernetes_api = Ionoscloud::KubernetesApi.new(api_client)

        @name_args.each do |node_id|
          begin
            node = kubernetes_api.k8s_nodepools_nodes_find_by_id(config[:cluster_id], config[:nodepool_id], node_id)
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("K8s Node ID #{node_id} not found. Skipping.")
            next
          end
          print_k8s_node(node)

          puts "\n"

          begin
            confirm('Do you really want to delete this K8s Node')
          rescue SystemExit => exc
            next
          end

          kubernetes_api.k8s_nodepools_nodes_delete(config[:cluster_id], config[:nodepool_id], node.id)
          ui.warn("Deleted K8s Node #{node.id}.")
        end
      end
    end
  end
end
