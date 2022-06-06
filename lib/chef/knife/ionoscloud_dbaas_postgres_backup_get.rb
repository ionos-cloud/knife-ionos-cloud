require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudDbaasPostgresBackupGet < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud dbaas postgres cluster get (options)'

      option :backup_id,
              short: '-B BACKUP_ID',
              long: '--backup-id BACKUP_ID',
              description: 'ID of the cluster backup'

      def initialize(args = [])
        super(args)
        @description =
        'Retrieve a PostgreSQL cluster backup by using its ID. This value can be '\
        'found when you GET a list of PostgreSQL cluster backups.'
        @directory = 'dbaas-postgres'
        @required_options = [:backup_id]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        print_cluster_backup(IonoscloudDbaasPostgres::BackupsApi.new(api_client_dbaas).clusters_backups_find_by_id(config[:backup_id]))
      end
    end
  end
end
