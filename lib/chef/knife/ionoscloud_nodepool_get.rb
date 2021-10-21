require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudNodepoolGet < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud nodepool get (options)'

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
        'Retrieves the attributes of a given K8S Nodepool.'
        @required_options = [:cluster_id, :nodepool_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        print_k8s_nodepool(
          Ionoscloud::KubernetesApi.new(api_client).k8s_nodepools_find_by_id(
            config[:cluster_id],
            config[:nodepool_id],
          ),
        )
      end
    end
  end
end
