require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudNodeList < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud node list'

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
        'Retrieve a list of Kubernetes Nodes in a Nodepool.'
        @required_options = [:cluster_id, :nodepool_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        node_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Public IP', :bold),
          ui.color('Private IP', :bold),
          ui.color('K8s Version', :bold),
          ui.color('State', :bold),
        ]

        kubernetes_api = Ionoscloud::KubernetesApi.new(api_client)

        kubernetes_api.k8s_nodepools_nodes_get(config[:cluster_id], config[:nodepool_id], { depth: 2 }).items.each do |node|
          node_list << node.id
          node_list << node.properties.name
          node_list << node.properties.public_ip
          node_list << node.properties.private_ip
          node_list << node.properties.k8s_version
          node_list << node.metadata.state
        end
        puts ui.list(node_list, :uneven_columns_across, 6)
      end
    end
  end
end
