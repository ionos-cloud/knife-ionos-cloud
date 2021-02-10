require 'chef/knife/ionoscloud_base'

class Chef
  class Knife
    class IonoscloudNodepoolList < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud nodepool list'

      option :cluster_id,
              short: '-C CLUSTER_ID',
              long: '--cluster-id CLUSTER_ID',
              description: 'The ID of the K8s Cluster'

      def run
        validate_required_params(%i(cluster_id), config)

        nodepool_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('K8s Version', :bold),
          ui.color('Datacenter ID', :bold),
          ui.color('Node Count', :bold),
          # ui.color('CPU Family', :bold),
          # ui.color('Cores Count', :bold),
          # ui.color('RAM', :bold),
          # ui.color('Storage Type', :bold),
          # ui.color('Storage Size', :bold),
          ui.color('State', :bold),
        ]

        kubernetes_api = Ionoscloud::KubernetesApi.new(api_client)

        kubernetes_api.k8s_nodepools_get(config[:cluster_id], { depth: 1 }).items.each do |nodepool|
          nodepool_list << nodepool.id
          nodepool_list << nodepool.properties.name
          nodepool_list << nodepool.properties.k8s_version
          nodepool_list << nodepool.properties.datacenter_id
          nodepool_list << nodepool.properties.node_count.to_s
          # nodepool_list << nodepool.properties.cpu_family
          # nodepool_list << nodepool.properties.cores_count.to_s
          # nodepool_list << nodepool.properties.ram_size.to_s
          # nodepool_list << nodepool.properties.storage_type
          # nodepool_list << nodepool.properties.storage_size.to_s
          nodepool_list << nodepool.metadata.state
        end
        puts ui.list(nodepool_list, :uneven_columns_across, 6)
      end
    end
  end
end