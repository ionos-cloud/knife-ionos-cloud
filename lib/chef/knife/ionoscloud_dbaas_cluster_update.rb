require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudDbaasClusterUpdate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud dbaas cluster update (options)'

      option :cluster_id,                              # todo vezi ce alte option sunt pentru update
      short: '-C CLUSTER_ID',
      long: '--cluster-id CLUSTER_ID',
      description: 'ID of the cluster'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Updates information about a Ionoscloud Dbaas Cluster.'
        @required_options = [:cluster_id, :ionoscloud_username, :ionoscloud_password]   # todo vezi daca trebuie schimbat ceva aici
        @updatable_fields = [:name, :description, :sec_auth_protection]                 # todo vezi daca trebuie schimbat ceva aici
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        clusters_api = IonoscloudDbaas::ClustersApi.new(api_client_dbaas)

        if @updatable_fields.map { |el| config[el] }.any?
          print "#{ui.color('Updating cluster...', :magenta)}"

          cluster, _, headers  = clusters_api.clusters_patch_with_http_info(
            config[:cluster_id],
            Ionoscloud::ClusterProperties.new(              # todo vezi daca sunt doar description si name sau treuiesc si altele adaugate
              name: config[:name],
              description: config[:description],
              sec_auth_protection: (config.key?(:sec_auth_protection) ? config[:sec_auth_protection].to_s.downcase == 'true' : nil),
            )
          )

          dot = ui.color('.', :magenta)
          api_client.wait_for { print dot; is_done? get_request_id headers }
        else
          ui.warn("Nothing to update, please set one of the attributes #{@updatable_fields}.")
        end

        print_cluster(clusters_api.clusters_find_by_id(config[:cluster_id]))
      end
    end
  end
end
