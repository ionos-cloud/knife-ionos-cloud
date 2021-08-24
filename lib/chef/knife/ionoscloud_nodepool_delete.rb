require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudNodepoolDelete < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud nodepool delete NODEPOOL_ID [NODEPOOL_ID] (options)'

      option :cluster_id,
              short: '-C CLUSTER_ID',
              long: '--cluster-id CLUSTER_ID',
              description: 'The ID of the K8s Cluster'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Deletes a node pool within an existing Kubernetes cluster.'
        @required_options = [:cluster_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        validate_required_params

        kubernetes_api = Ionoscloud::KubernetesApi.new(api_client)

        @name_args.each do |nodepool_id|
          begin
            nodepool = kubernetes_api.k8s_nodepools_find_by_id(config[:cluster_id], nodepool_id)
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("K8s Nodepool ID #{nodepool_id} not found. Skipping.")
            next
          end

          auto_scaling = "Min node count: #{nodepool.properties.auto_scaling.min_node_count}, Max node count:#{nodepool.properties.auto_scaling.max_node_count}"
          maintenance_window = "#{nodepool.properties.maintenance_window.day_of_the_week}, #{nodepool.properties.maintenance_window.time}"

          msg_pair('ID', nodepool.id)
          msg_pair('Name', nodepool.properties.name)
          msg_pair('K8s Version', nodepool.properties.k8s_version)
          msg_pair('Datacenter ID', nodepool.properties.datacenter_id)
          msg_pair('Node Count', nodepool.properties.node_count)
          msg_pair('CPU Family', nodepool.properties.cpu_family)
          msg_pair('Cores Count', nodepool.properties.cores_count)
          msg_pair('RAM', nodepool.properties.ram_size)
          msg_pair('Storage Type', nodepool.properties.storage_type)
          msg_pair('Storage Size', nodepool.properties.storage_size)
          msg_pair('Lans', nodepool.properties.lans.map do
            |lan|
            {
              id: lan.id,
              dhcp: lan.dhcp,
              routes: lan.routes ? lan.routes.map do
                |route|
                {
                  network: route.network,
                  gateway_ip: route.gateway_ip,
                }
              end : []
            }
          end)
          msg_pair('Availability Zone', nodepool.properties.availability_zone)
          msg_pair('Auto Scaling', auto_scaling)
          msg_pair('Maintenance Window', maintenance_window)
          msg_pair('State', nodepool.metadata.state)

          puts "\n"

          begin
            confirm('Do you really want to delete this K8s Nodepool')
          rescue SystemExit => exc
            next
          end

          kubernetes_api.k8s_nodepools_delete(config[:cluster_id], nodepool.id)
          ui.warn("Deleted K8s Nodepool #{nodepool.id}.")
        end
      end
    end
  end
end
