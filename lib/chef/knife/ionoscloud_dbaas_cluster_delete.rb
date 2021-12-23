require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudDbaasClusterDelete < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud dbaas cluster delete CLUSTER_ID [CLUSTER_ID]'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Delete a Ionoscloud Dbaas Cluster'
        @required_options = [:ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        clusters_api = IonoscloudDbaas::ClustersApi.new(api_client_dbaas)

        @name_args.each do |cluster_id|
          begin
            cluster = clusters_api.clusters_find_by_id(cluster_id)
          rescue IonoscloudDbaas::ApiError => err
            raise err unless err.code == 404
            ui.error("Cluster ID #{cluster_id} not found. Skipping.")
            next
          end

          print_cluster(cluster)
          puts "\n"

          begin
            confirm('Do you really want to delete this cluster')
          rescue SystemExit => exc
            next
          end

          _, _, headers = clusters_api.clusters_delete_with_http_info(cluster_id)
          ui.warn("Deleted Cluster #{cluster.id}.")
        end
      end
    end
  end
end
