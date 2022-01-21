require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudDbaasVersionList < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud dbaas version list'

      option :cluster_id,
              short: '-C CLUSTER_ID',
              long: '--cluster-id CLUSTER_ID',
              description: 'ID of the cluster'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Retrieves a list of all available PostgreSQL versions.'
        @required_options = [:ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        version_list = [
          ui.color('Version', :bold),
        ]

        clusters_api = IonoscloudDbaas::ClustersApi.new(api_client_dbaas)

        if config[:cluster_id]
          versions = clusters_api.cluster_postgres_versions_get(config[:cluster_id])
        else
          versions = clusters_api.postgres_versions_get()
        end

        versions.data.each do |version|
          version_list << version.name
        end

        puts ui.list(version_list, :uneven_columns_across, 1)
      end
    end
  end
end
