require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudDbaasClusterGet < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud dbaas cluster get (options)'

      option :cluster_id,
              short: '-C CLUSTER_ID',
              long: '--cluster-id CLUSTER_ID',
              description: 'ID of the cluster'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Retrieves information about a Ionoscloud DBaaS Cluster.'
        @required_options = [:cluster_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        print_cluster(IonoscloudDbaas::ClustersApi.new(api_client_dbaas).clusters_find_by_id(config[:cluster_id]))
      end
    end
  end
end
