require 'chef/knife/ionoscloud_base'

class Chef
  class Knife
    class IonoscloudKubeconfigGet < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud kubeconfig get (options)'

      option :cluster_id,
             short: '-C CLUSTER_ID',
             long: '--cluster-id CLUSTER_ID',
             description: 'The ID of the Kubernetes cluster.'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Retrieve the kubeconfig file for a given Kubernetes cluster.'
        @required_options = [:cluster_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        validate_required_params(@required_options, config)

        puts Ionoscloud::KubernetesApi.new(api_client).k8s_kubeconfig_get(config[:cluster_id])
      end
    end
  end
end
