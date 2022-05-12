require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudK8sList < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud k8s list'

      def initialize(args = [])
        super(args)
        @description =
        'Retrieve a list of Kubernetes clusters.'
        @directory = 'kubernetes'
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        cluster_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Public', :bold),
          ui.color('Version', :bold),
          ui.color('Maintenance Window', :bold),
          ui.color('State', :bold),
        ]

        kubernetes_api = Ionoscloud::KubernetesApi.new(api_client)

        kubernetes_api.k8s_get({ depth: 1 }).items.each do |cluster|
          cluster_list << cluster.id
          cluster_list << cluster.properties.name
          cluster_list << cluster.properties.public
          cluster_list << cluster.properties.k8s_version
          cluster_list << "#{cluster.properties.maintenance_window.day_of_the_week}, #{cluster.properties.maintenance_window.time}"
          cluster_list << cluster.metadata.state
        end

        puts ui.list(cluster_list, :uneven_columns_across, 6)
      end
    end
  end
end
