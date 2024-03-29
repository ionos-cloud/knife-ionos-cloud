require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudDbaasPostgresClusterGet < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud dbaas postgres cluster get (options)'

      option :cluster_id,
              short: '-C CLUSTER_ID',
              long: '--cluster-id CLUSTER_ID',
              description: 'ID of the cluster'

      def initialize(args = [])
        super(args)
        @description =
        'You can retrieve a PostgreSQL cluster by using its ID. This value can be '\
        'found in the response body when a PostgreSQL cluster is created or when '\
        'you GET a list of PostgreSQL clusters.'
        @directory = 'dbaas-postgres'
        @required_options = [:cluster_id]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        print_cluster(IonoscloudDbaasPostgres::ClustersApi.new(api_client_dbaas).clusters_find_by_id(config[:cluster_id]))
      end
    end
  end
end
