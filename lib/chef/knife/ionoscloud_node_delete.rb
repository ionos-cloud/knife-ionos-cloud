require 'chef/knife/ionoscloud_base'

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
        @required_options = [:cluster_id, :nodepool_id]
      end

      def run
        validate_required_params(@required_options, config)
        $stdout.sync = true

        kubernetes_api = Ionoscloud::KubernetesApi.new(api_client)

        @name_args.each do |node_id|
          begin
            node = kubernetes_api.k8s_nodepools_nodes_find_by_id(config[:cluster_id], config[:nodepool_id], node_id)
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("K8s Node ID #{node_id} not found. Skipping.")
            next
          end

          msg_pair('ID', node.id)
          msg_pair('Name', node.properties.name)
          msg_pair('Public IP', node.properties.public_ip)
          msg_pair('K8s Version', node.properties.k8s_version)
          msg_pair('State', node.metadata.state)

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
