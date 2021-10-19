require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudDbaasClusterCreate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud dbaas cluster create (options)'

      option :postgres_version,
              long: '--postgres-version POSTGRES_VERSION',
              description: 'The PostgreSQL version of your cluster'

      option :replicas,
              short: '-R REPLICAS',
              long: '--replicas REPLICAS',
              description: 'The total number of instances in the cluster (one master and n-1 standbys).'

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

      option :storage_type,
              long: '--type STORAGE_TYPE',
              description: 'The storage type used in your cluster.'

      option :vdc_connections,
              long: '--vdc-connections VDC_CONNECTIONS',
              description: 'Array of VDCs to connect to your cluster.'

      option :location,
              short: '-l LOCATION',
              long: '--location LOCATION',
              description: 'The physical location where the cluster will be created. This will
                            be where all of your instances live. Property cannot be modified
                            after datacenter creation (disallowed in update requests)'

      option :display_name,
              short: '-n DISPLAY_NAME',
              long: '--name DISPLAY_NAME',
              description: 'The friendly name of your cluster.'

      option :backup_enabled,
              short: '-b BACKUP_ENABLED',
              long: '--backup-enabled BACKUP_ENABLED',
              description: 'Deprecated: backup is always enabled. Enables automatic backups of your cluster.'

      option :time,
              long: '--time TIME',
              description: 'Time Of the day when to perform the maintenance.'

      option :weekday,
              short: '-d WEEKDAY',
              long: '--weekday WEEKDAY',
              description: 'Day Of the week when to perform the maintenance.'

      option :username,
              long: '--db-user DB_USERNAME',
              description: 'The username for the initial postgres user.
                            Some system usernames are restricted (e.g. "postgres", "admin", "standby")'

      option :password,
              long: '--db-password DB_PASSWORD',
              description: 'The username for the initial postgres user.'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Creates a new PostgreSQL cluster.'
        @required_options = [
          :postgres_version, :replicas, :cpu_core_count, :ram_size, :storage_size, :storage_type,
          :vdc_connections, :location, :display_name, :username, :password, :ionoscloud_username, :ionoscloud_password,
        ]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        print "#{ui.color('Creating cluster...', :magenta)}"

        config[:vdc_connections] = JSON[config[:vdc_connections]] if config[:vdc_connections] && config[:vdc_connections].instance_of?(String)

        config[:vdc_connections] = config[:vdc_connections].map do
          |vdc_connection|
          IonoscloudDbaas::VDCConnection.new(
            vdc_id: vdc_connection['vdc_id'],
            lan_id: String(vdc_connection['lan_id']),
            ip_address: vdc_connection['ip_address'],
          )
        end if config[:vdc_connections]

        clusters_api = IonoscloudDbaas::ClustersApi.new(api_client_dbaas)

        cluster, _, headers  = clusters_api.clusters_post_with_http_info(
          IonoscloudDbaas::CreateClusterRequest.new(
            postgres_version: config[:postgres_version],
            replicas: Integer(config[:replicas]),
            cpu_core_count: Integer(config[:cpu_core_count]),
            ram_size: config[:ram_size],
            storage_size: config[:storage_size],
            storage_type: config[:storage_type],
            vdc_connections: config[:vdc_connections],
            location: config[:location],
            display_name: config[:display_name],
            backup_enabled: config[:backup_enabled],
            maintenance_window: (config[:time] && config[:weekday]) ? IonoscloudDbaas::MaintenanceWindow.new(
              time: config[:time],
              weekday: config[:weekday],
            ) : nil,
            credentials: IonoscloudDbaas::DBUser.new(
              username: config[:username],
              password: config[:password],
            ),
          ),
        )

        print_cluster(cluster)
      end
    end
  end
end
