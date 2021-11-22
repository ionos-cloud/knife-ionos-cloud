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
        'If cluster_id is provided, retrieves a list of all backups of the given PostgreSQL cluster,
        otherwise retrieves a list of all PostgreSQL cluster backups.'
        @required_options = [:ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        backup_list = [
          ui.color('ID', :bold),
          ui.color('Cluster ID', :bold),
          ui.color('Display Name', :bold),
          ui.color('Type', :bold),
          ui.color('Time', :bold),
        ]

        backups_api = IonoscloudDbaas::BackupsApi.new(api_client_dbaas)

        if config[:cluster_id]
          backups = backups_api.cluster_backups_get(config[:cluster_id])
        else
          backups = backups_api.clusters_backups_get()
        end

        backups.data.each do |backup|
          backup_list << backup.id
          backup_list << backup.cluster_id
          backup_list << backup.display_name
          backup_list << backup.type
          backup_list << backup.metadata.created_date
        end

        puts ui.list(backup_list, :uneven_columns_across, 5)
      end
    end
  end
end
