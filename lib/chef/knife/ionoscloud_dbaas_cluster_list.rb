require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudDbaasClusterList < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud dbaas cluster list'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'retrieves a list of all PostgreSQL clusters.' # todo trebuie sa vad daca pot face mai explicita descrierea
        @required_options = [:ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        dbaas_cluster_list = [
          ui.color('ID', :bold),
          ui.color('Postgres Version', :bold),
          ui.color('Instances', :bold),
          ui.color('Cores', :bold),
          ui.color('RAM', :bold),
          ui.color('Storage Size', :bold),
          ui.color('Storage Type', :bold),
          ui.color('Connections', :bold),
          ui.color('Location', :bold),
          ui.color('Display Name', :bold),
          ui.color('Maintenance Window', :bold),
          ui.color('Synchronization Mode', :bold),
          # ui.color('From Backup', :bold),
        ]

        clusters_api = IonoscloudDbaas::ClustersApi.new(api_client_dbaas)

        clusters_api.clusters_get({ depth: 1 }).items.each do |cluster|
          dbaas_cluster_list << cluster.id
          dbaas_cluster_list << cluster.properties.postgres_version
          dbaas_cluster_list << cluster.properties.instances
          dbaas_cluster_list << cluster.properties.cores
          dbaas_cluster_list << cluster.properties.ram
          dbaas_cluster_list << cluster.properties.storage_size
          dbaas_cluster_list << cluster.properties.storage_type
          dbaas_cluster_list << cluster.properties.connections
          dbaas_cluster_list << cluster.properties.location
          dbaas_cluster_list << cluster.properties.display_name
          dbaas_cluster_list << cluster.properties.maintenance_window
          dbaas_cluster_list << cluster.properties.synchronization_mode
          # dbaas_cluster_list << cluster.properties.from_backup
        end

        puts ui.list(dbaas_cluster_list, :uneven_columns_across, 12)
      end
    end
  end
end
