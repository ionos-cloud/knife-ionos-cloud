require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudDbaasBackupGet < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud dbaas cluster get (options)'

      option :backup_id,
              short: '-B BACKUP_ID',
              long: '--backup-id BACKUP_ID',
              description: 'ID of the cluster backup'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Retrieves information about a Ionoscloud DBaaS Cluster Backup.'
        @required_options = [:backup_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        print_cluster_backup(IonoscloudDbaas::BackupsApi.new(api_client_dbaas).clusters_backups_find_by_id(config[:backup_id]))
      end
    end
  end
end