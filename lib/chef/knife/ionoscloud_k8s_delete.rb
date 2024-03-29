require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudK8sDelete < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud k8s delete CLUSTER_ID [CLUSTER_ID]'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Deletes a Kubernetes cluster. The cluster cannot contain any node pools when deleting.'
        @required_options = [:ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        kubernetes_api = Ionoscloud::KubernetesApi.new(api_client)

        @name_args.each do |cluster_id|
          begin
            cluster = kubernetes_api.k8s_find_by_cluster_id(cluster_id, { depth: 2 })
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("K8s Cluster ID #{cluster_id} not found. Skipping.")
            next
          end

          unless ['ACTIVE', 'TERMINATED'].include? cluster.metadata.state
            ui.error(
              "K8s Cluster #{cluster_id} state must be one of ['ACTIVE', 'TERMINATED'], "\
              "actual state is '#{cluster.metadata.state}'. Skipping."
            )
            next
          end

          if cluster.entities.nodepools.items.length > 0
            ui.error("K8s Cluster ID #{cluster_id} has existing Nodepools. Skipping.")
            next
          end

          msg_pair('ID', cluster.id)
          msg_pair('Name', cluster.properties.name)
          msg_pair('Version', cluster.properties.k8s_version)
          msg_pair(
            'Maintenance Window',
            "#{cluster.properties.maintenance_window.day_of_the_week}, #{cluster.properties.maintenance_window.time}",
          )
          msg_pair('State', cluster.metadata.state)

          puts "\n"

          begin
            confirm('Do you really want to delete this K8s Cluster')
          rescue SystemExit => exc
            next
          end

          _, _, headers = kubernetes_api.k8s_delete_with_http_info(cluster.id)
          ui.warn("Deleted K8s Cluster #{cluster.id}. Request ID: #{get_request_id headers}")
        end
      end
    end
  end
end
