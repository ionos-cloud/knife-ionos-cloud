require_relative 'ionoscloud_base'

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

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        "You can recreate a single Kubernetes Node.\n\n"\
        "Managed Kubernetes starts a process which based on the nodepool\'s "\
        "template creates & configures a new node, waits for status \"ACTIVE\", "\
        "and migrates all the pods from the faulty node, deleting it once empty. "\
        "While this operation occurs, the nodepool will have an extra billable \"ACTIVE\" node."
        @required_options = [:cluster_id, :nodepool_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        validate_required_params(@required_options, config)

        kubernetes_api = Ionoscloud::KubernetesApi.new(api_client)

        @name_args.each do |node_id|
          begin
            kubernetes_api.k8s_nodepools_nodes_replace_post(config[:cluster_id], config[:nodepool_id], node_id)
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("K8s Node ID #{node_id} not found. Skipping.")
            next
          end

          ui.warn("Recreated K8s Node #{node_id}.")
        end
      end
    end
  end
end
