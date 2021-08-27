require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudK8sGet < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud k8s get (options)'

      option :cluster_id,
              short: '-C CLUSTER_ID',
              long: '--cluster-id CLUSTER_ID',
              description: 'ID of the Kubernetes cluster'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Retrieves information about a K8s Cluster.'
        @required_options = [:cluster_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        print_k8s_cluster(Ionoscloud::KubernetesApi.new(api_client).k8s_find_by_cluster_id(config[:cluster_id]))
      end
    end
  end
end