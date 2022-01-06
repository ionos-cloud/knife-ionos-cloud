require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudDbaasPostgresClusterUpdate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud dbaas postgres cluster update (options)'

      option :cluster_id,
              short: '-C CLUSTER_ID',
              long: '--cluster-id CLUSTER_ID',
              description: 'ID of the cluster'

      option :cores,
              short: '-C CORES',
              long: '--cores CORES',
              description: 'The number of CPU cores per instance.'

      option :ram_size,
              short: '-r RAM',
              long: '--ram RAM',
              description: 'The amount of memory per instance.'

      option :storage_size,
              long: '--size STORAGE_SIZE',
              description: 'The amount of storage per instance.'

      option :connections,
              long: '--connections CONNECTIONS',
              description: 'Array of VDCs to connect to your cluster.'

      option :display_name,
              short: '-n DISPLAY_NAME',
              long: '--name DISPLAY_NAME',
              description: 'The friendly name of your cluster.'

      option :time,
              long: '--time TIME',
              description: 'Time Of the day when to perform the maintenance.'

      option :weekday,
              short: '-d WEEKDAY',
              long: '--weekday WEEKDAY',
              description: 'Day Of the week when to perform the maintenance.'

      option :postgres_version,
              long: '--postgres-version POSTGRES_VERSION',
              description: 'The PostgreSQL version of your cluster'

      option :instances,
              short: '-R INSTANCES',
              long: '--instances INSTANCES',
              description: 'The total number of instances in the cluster (one master and n-1 standbys).'


      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Updates information about a Ionoscloud Dbaas Cluster.'
        @required_options = [:cluster_id, :ionoscloud_username, :ionoscloud_password]
        @updatable_fields = [:cores, :ram, :storage_size, :display_name, :time, :weekday, :postgres_version, :instances]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        clusters_api = IonoscloudDbaasPostgres::ClustersApi.new(api_client_dbaas)

        if @updatable_fields.map { |el| config[el] }.any?
          print "#{ui.color('Updating cluster...', :magenta)}"

          cluster_properties = IonoscloudDbaasPostgres::PatchClusterProperties.new(
            cores: (config[:cores].nil? ? nil : Integer(config[:cores])),
            ram: (config[:ram].nil? ? nil : Integer(config[:ram])),
            storage_size: (config[:storage_size].nil? ? nil : Integer(config[:storage_size])),
            display_name: config[:display_name],
            maintenance_window: (config[:time] && config[:weekday]) ? IonoscloudDbaasPostgres::MaintenanceWindow.new(
              time: config[:time],
              weekday: config[:weekday],
            ) : nil,
            postgres_version: config[:postgres_version],
            instances: config[:instances],
          )
          cluster_request = IonoscloudDbaasPostgres::PatchClusterRequest.new()
          cluster_request.properties = cluster_properties

          cluster, _, headers  = clusters_api.clusters_patch_with_http_info(config[:cluster_id], cluster_request)

          dot = ui.color('.', :magenta)
        else
          ui.warn("Nothing to update, please set one of the attributes #{@updatable_fields}.")
        end

        print_cluster(clusters_api.clusters_find_by_id(config[:cluster_id]))
      end
    end
  end
end
