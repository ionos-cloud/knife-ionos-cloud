require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudDbaasBackupList < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud dbaas backup list (options)'

      option :cluster_id,
              short: '-C CLUSTER_ID',
              long: '--cluster-id CLUSTER_ID',
              description: 'ID of the cluster'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Retrieves a list of all PostgreSQL cluster backups.'
        @required_options = [:ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        backup_list = [
          ui.color('ID', :bold),
          ui.color('Type', :bold),
          ui.color('Cluster ID', :bold),
          ui.color('Display Name', :bold),
          ui.color('Is Active', :bold),
          ui.color('Earliest Recovery Target Time', :bold),
          ui.color('Created Date', :bold),
        ]

        backups_api = IonoscloudDbaas::BackupsApi.new(api_client_dbaas)

        if config[:cluster_id]
          backups = backups_api.cluster_backups_get(config[:cluster_id])
        else
          backups = backups_api.clusters_backups_get()
        end

        backups.items.each do |backup|
          backup_list << backup.id
          backup_list << backup.type
          backup_list << backup.properties.cluster_id
          backup_list << backup.properties.display_name
          backup_list << backup.properties.is_active
          backup_list << backup.properties.earliest_recovery_target_time
          backup_list << backup.metadata.created_date
        end

        puts ui.list(backup_list, :uneven_columns_across, 7)
      end
    end
  end
end
