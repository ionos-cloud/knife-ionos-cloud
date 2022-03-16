require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudNodepoolList < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud nodepool list'

      option :cluster_id,
              short: '-C CLUSTER_ID',
              long: '--cluster-id CLUSTER_ID',
              description: 'The ID of the K8s Cluster'

      def initialize(args = [])
        super(args)
        @description =
        'Retrieve a list of all node pools contained in a selected Kubernetes cluster.'
        @directory = 'kubernetes'
        @required_options = [:cluster_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        nodepool_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('K8s Version', :bold),
          ui.color('Datacenter ID', :bold),
          ui.color('Gateway IP', :bold),
          ui.color('Node Count', :bold),
          ui.color('Lan Count', :bold),
          ui.color('State', :bold),
        ]

        kubernetes_api = Ionoscloud::KubernetesApi.new(api_client)

        kubernetes_api.k8s_nodepools_get(config[:cluster_id], { depth: 1 }).items.each do |nodepool|
          nodepool_list << nodepool.id
          nodepool_list << nodepool.properties.name
          nodepool_list << nodepool.properties.k8s_version
          nodepool_list << nodepool.properties.datacenter_id
          nodepool_list << nodepool.properties.gateway_ip
          nodepool_list << nodepool.properties.node_count.to_s
          nodepool_list << nodepool.properties.lans.length
          nodepool_list << nodepool.metadata.state
        end
        puts ui.list(nodepool_list, :uneven_columns_across, 8)
      end
    end
  end
end
