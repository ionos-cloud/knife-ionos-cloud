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

        def run
        $stdout.sync = true
        validate_required_params(%i(cluster_id), config)

        puts Ionoscloud::KubernetesApi.new(api_client).k8s_kubeconfig_get(config[:cluster_id])
      end
    end
  end
end
