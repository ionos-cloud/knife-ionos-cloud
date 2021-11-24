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

      option :cpu_core_count,
              short: '-C CORES_COUNT',
              long: '--cores CORES_COUNT',
              description: 'The number of CPU cores per instance.'

      option :ram_size,
              short: '-r RAM_SIZE',
              long: '--ram RAM_SIZE',
              description: 'The amount of memory per instance.'

      option :storage_size,
              long: '--size STORAGE_SIZE',
              description: 'The amount of storage per instance.'

      option :backup_enabled,
              short: '-b BACKUP_ENABLED',
              long: '--backup-enabled BACKUP_ENABLED',
              description: 'Deprecated: backup is always enabled. Enables automatic backups of your cluster.'

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

      option :replicas,
              short: '-R REPLICAS',
              long: '--replicas REPLICAS',
              description: 'The total number of instances in the cluster (one master and n-1 standbys).'
      

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Updates information about a Ionoscloud Dbaas Cluster.'
        @required_options = [:cluster_id] 
        @updatable_fields = [:cpu_core_count, :ram_size, :storage_size, :backup_enabled, :display_name, :time, :weekday, :postgres_version, :replicas] 
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
            IonoscloudDbaas::PatchClusterRequest.new(
              cpu_core_count: config[:cpu_core_count],
              ram_size: config[:ram_size],
              storage_size: config[:storage_size],
              backup_enabled: config[:backup_enabled],
              display_name: config[:display_name],
              maintenance_window: (config[:time] && config[:weekday]) ? IonoscloudDbaas::MaintenanceWindow.new(
                time: config[:time],
                weekday: config[:weekday],
              ) : nil,
              postgres_version: config[:postgres_version],
              replicas: config[:replicas],
            )
          )

          dot = ui.color('.', :magenta)
        else
          ui.warn("Nothing to update, please set one of the attributes #{@updatable_fields}.")
        end

        print_cluster(clusters_api.clusters_find_by_id(config[:cluster_id]))
      end
    end
  end
end
