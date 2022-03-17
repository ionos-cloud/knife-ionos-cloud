require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudDbaasPostgresClusterList < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud dbaas postgres cluster list'

      def initialize(args = [])
        super(args)
        @description =
        'Retrieves a list of PostgreSQL clusters.'
        @directory = 'dbaas-postgres'
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
          ui.color('Datacenter ID', :bold),
          ui.color('Lan ID', :bold),
          ui.color('cidr', :bold),
          ui.color('Status', :bold),
        ]

        clusters_api = IonoscloudDbaasPostgres::ClustersApi.new(api_client_dbaas)

        clusters_api.clusters_get(depth: 1).items.each do |cluster|
          dbaas_cluster_list << cluster.id
          dbaas_cluster_list << cluster.properties.display_name
          dbaas_cluster_list << cluster.properties.postgres_version
          dbaas_cluster_list << cluster.properties.location
          dbaas_cluster_list << cluster.properties.instances
          dbaas_cluster_list << cluster.properties.connections.first.datacenter_id
          dbaas_cluster_list << cluster.properties.connections.first.lan_id
          dbaas_cluster_list << cluster.properties.connections.first.cidr
          dbaas_cluster_list << cluster.metadata.state
        end

        puts ui.list(dbaas_cluster_list, :uneven_columns_across, 9)
      end
    end
  end
end
