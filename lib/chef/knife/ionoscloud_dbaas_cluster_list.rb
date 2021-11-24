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
          ui.color('Display Name', :bold),
          ui.color('Postgres Version', :bold),
          ui.color('Location', :bold),
          ui.color('Replicas', :bold),
          ui.color('RAM Size', :bold),
          ui.color('CPU Core Count', :bold),
          ui.color('Storage Size', :bold),
          ui.color('Storage Type', :bold),
          ui.color('Backup Enabled', :bold),
          ui.color('VDC Connections', :bold),
          ui.color('Maintenance Window', :bold),
          ui.color('Lifecycle Status', :bold),
          ui.color('Synchronization Mode', :bold),
        ]

        clusters_api = IonoscloudDbaas::ClustersApi.new(api_client_dbaas)

        
        clusters_api.clusters_get({ depth: 1 }).data.each do |cluster|
          dbaas_cluster_list << cluster.id
          dbaas_cluster_list << cluster.display_name
          dbaas_cluster_list << cluster.postgres_version
          dbaas_cluster_list << cluster.location
          dbaas_cluster_list << cluster.replicas
          dbaas_cluster_list << cluster.ram_size
          dbaas_cluster_list << cluster.cpu_core_count
          dbaas_cluster_list << cluster.storage_size
          dbaas_cluster_list << cluster.storage_type
          dbaas_cluster_list << cluster.backup_enabled
          dbaas_cluster_list << cluster.vdc_connections
          dbaas_cluster_list << cluster.maintenance_window
          dbaas_cluster_list << cluster.lifecycle_status
          dbaas_cluster_list << cluster.synchronization_mode
        end

        puts ui.list(dbaas_cluster_list, :uneven_columns_across, 14)
      end
    end
  end
end
