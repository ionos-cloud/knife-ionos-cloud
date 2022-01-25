require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudDbaasPostgresClusterList < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud dbaas postgres cluster list'

      def initialize(args = [])
        super(args)
        @description =
        'retrieves a list of all PostgreSQL clusters.'
        @directory = 'dbaas-postgres'
        @required_options = [:ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        dbaas_cluster_list = [
          ui.color('ID', :bold),
          ui.color('Display Name', :bold),
          ui.color('Postgres Version', :bold),
          ui.color('Location', :bold),
          ui.color('Instances', :bold),
          ui.color('Cores', :bold),
          ui.color('RAM Size', :bold),
          ui.color('Storage Size', :bold),
          ui.color('Storage Type', :bold),
          ui.color('Connections', :bold),
          ui.color('Maintenance Window', :bold),
          ui.color('Synchronization Mode', :bold),
          ui.color('Lifecycle Status', :bold),
        ]

        clusters_api = IonoscloudDbaasPostgres::ClustersApi.new(api_client_dbaas)

        clusters_api.clusters_get({ depth: 1 }).items.each do |cluster|
          dbaas_cluster_list << cluster.id
          dbaas_cluster_list << cluster.properties.display_name
          dbaas_cluster_list << cluster.properties.postgres_version
          dbaas_cluster_list << cluster.properties.location
          dbaas_cluster_list << cluster.properties.instances
          dbaas_cluster_list << cluster.properties.cores
          dbaas_cluster_list << cluster.properties.ram
          dbaas_cluster_list << cluster.properties.storage_size
          dbaas_cluster_list << cluster.properties.storage_type
          dbaas_cluster_list << cluster.properties.connections
          dbaas_cluster_list << cluster.properties.maintenance_window
          dbaas_cluster_list << cluster.properties.synchronization_mode
          dbaas_cluster_list << cluster.metadata.state
        end

        puts ui.list(dbaas_cluster_list, :uneven_columns_across, 13)
      end
    end
  end
end
