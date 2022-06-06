require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudNodeGet < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud node get (options)'

      option :cluster_id,
              short: '-C CLUSTER_ID',
              long: '--cluster-id CLUSTER_ID',
              description: 'The ID of the K8s Cluster'

      option :nodepool_id,
              short: '-P NODEPOOL_ID',
              long: '--nodepool-id NODEPOOL_ID',
              description: 'The ID of the K8s Nodepool'

      option :node_id,
              short: '-N NODE_ID',
              long: '--node-id NODE_ID',
              description: 'ID of the load balancer'

      def initialize(args = [])
        super(args)
        @description =
        'Retrieves the attributes of a given K8S Node.'
        @directory = 'kubernetes'
        @required_options = [:cluster_id, :nodepool_id, :node_id]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        print_k8s_node(
          Ionoscloud::KubernetesApi.new(api_client).k8s_nodepools_nodes_find_by_id(
            config[:cluster_id],
            config[:nodepool_id],
            config[:node_id],
          ),
        )
      end
    end
  end
end
