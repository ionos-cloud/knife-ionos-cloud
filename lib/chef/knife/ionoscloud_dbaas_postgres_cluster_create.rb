require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudDbaasPostgresClusterCreate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud dbaas postgres cluster create (options)'

      option :postgres_version,
              long: '--postgres-version POSTGRES_VERSION',
              description: 'The PostgreSQL version of your cluster'

      option :instances,
              short: '-R INSTANCES',
              long: '--instances INSTANCES',
              description: 'The total number of instances in the cluster (one master and n-1 standbys).'

      option :cores,
              short: '-C CORES',
              long: '--cores CORES',
              description: 'The number of CPU cores per instance.'

      option :ram,
              short: '-r RAM',
              long: '--ram RAM',
              description: 'The amount of memory per instance(should be a multiple of 1024).'

      option :storage_size,
              long: '--size STORAGE_SIZE',
              description: 'The amount of storage per instance.'

      option :storage_type,
              long: '--type STORAGE_TYPE',
              description: 'The storage type used in your cluster.'

      option :connections,
              long: '--connections CONNECTIONS',
              description: 'Array of VDCs to connect to your cluster.'

      option :location,
              short: '-l LOCATION',
              long: '--location LOCATION',
              description: 'The physical location where the cluster will be created. This will
                            be where all of your instances live. Property cannot be modified
                            after datacenter creation (disallowed in update requests)'

      option :backup_location,
              long: '--backup-location BACKUP_LOCATION',
              description: 'The S3 location where the backups will be stored.'

      option :display_name,
              short: '-n DISPLAY_NAME',
              long: '--name DISPLAY_NAME',
              description: 'The friendly name of your cluster.'

      option :from_backup,
              short: '-b FROM_BACKUP',
              long: '--from-backup FROM_BACKUP',
              description: 'Deprecated: backup is always enabled. Enables automatic backups of your cluster.'

      option :time,
              long: '--time TIME',
              description: 'Time Of the day when to perform the maintenance.'

      option :day_of_the_week,
              short: '-d DAY_OF_THE_WEEK',
              long: '--day-of-the-week DAY_OF_THE_WEEK',
              description: 'Day Of the week when to perform the maintenance.'

      option  :synchronization_mode,
               short: '-s SYNCHRONIZATION_MODE',
               long: '--synchronization-mode SYNCHRONIZATION_MODE',
               description: 'Represents different modes of replication. One of [ASYNCHRONOUS, SYNCHRONOUS, STRICTLY_SYNCHRONOUS]'

      option :username,
              long: '--db-user DB_USERNAME',
              description: 'The username for the initial postgres user.
                            Some system usernames are restricted (e.g. "postgres", "admin", "standby")'

      option :password,
              long: '--db-password DB_PASSWORD',
              description: 'The username for the initial postgres user.'

      option :backup_id,
              short: '-B BACKUP_ID',
              long: '--backup-id BACKUP_ID',
              description: 'ID of backup'

      option :recovery_target_time,
              short: '-T RECOVERY_TARGET_TIME',
              long: '--recovery-target-time RECOVERY_TARGET_TIME',
              description: 'Recovery target time'

      def initialize(args = [])
        super(args)
        @description =
        'Creates a new PostgreSQL cluster. '\
        'If the `fromBackup` field is populated, the new cluster will be created '\
        'based on the given backup.'
        @directory = 'dbaas-postgres'
        @required_options = [
          :postgres_version, :instances, :cores, :ram, :storage_size, :storage_type,
          :connections, :location, :display_name, :synchronization_mode, :username, :password,
        ]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        print "#{ui.color('Creating cluster...', :magenta)}"

        config[:connections] = JSON[config[:connections]] if config[:connections] && config[:connections].instance_of?(String)

        config[:connections] = config[:connections].map do |connection|
          IonoscloudDbaasPostgres::Connection.new(
            datacenter_id: connection['datacenter_id'],
            lan_id: String(connection['lan_id']),
            cidr: connection['cidr'],
          )
        end if config[:connections]

        clusters_api = IonoscloudDbaasPostgres::ClustersApi.new(api_client_dbaas)

        cluster_properties = IonoscloudDbaasPostgres::CreateClusterProperties.new(
          postgres_version: config[:postgres_version],
          instances: Integer(config[:instances]),
          cores: Integer(config[:cores]),
          ram: Integer(config[:ram]),
          storage_size: Integer(config[:storage_size]),
          storage_type: config[:storage_type],
          connections: config[:connections],
          location: config[:location],
          backup_location: config[:backup_location],
          display_name: config[:display_name],
          maintenance_window: (config[:time] && config[:day_of_the_week]) ? IonoscloudDbaasPostgres::MaintenanceWindow.new(
            time: config[:time],
            day_of_the_week: config[:day_of_the_week],
          ) : nil,
          credentials: IonoscloudDbaasPostgres::DBUser.new(
            username: config[:username],
            password: config[:password],
          ),
          synchronization_mode: config[:synchronization_mode],
          from_backup: IonoscloudDbaasPostgres::CreateRestoreRequest.new(
            backup_id: config[:backup_id],
            recovery_target_time: config[:recovery_target_time],
          ),
        )

        cluster_request = IonoscloudDbaasPostgres::CreateClusterRequest.new()
        cluster_request.properties = cluster_properties

        cluster, _, _  = clusters_api.clusters_post_with_http_info(cluster_request)

        print_cluster(cluster)
      end
    end
  end
end
