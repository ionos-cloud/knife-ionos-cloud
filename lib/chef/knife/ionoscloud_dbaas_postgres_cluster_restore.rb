require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudDbaasPostgresClusterRestore < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud dbaas postgres cluster restore (options)'

      option :cluster_id,
              short: '-C CLUSTER_ID',
              long: '--cluster-id CLUSTER_ID',
              description: 'ID of the cluster'

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
        'Restore a Ionoscloud DBaaS Cluster.'
        @directory = 'dbaas-postgres'
        @required_options = [:cluster_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        print "#{ui.color('Restoring Cluster...', :magenta)}"

        restore_request = IonoscloudDbaasPostgres::CreateRestoreRequest.new(backup_id: config[:backup_id], recovery_target_time: config[:recovery_target_time])

        IonoscloudDbaasPostgres::RestoresApi.new(api_client_dbaas).cluster_restore_post(config[:cluster_id], restore_request)

        puts("\nCluster restored succsefully.")
      end
    end
  end
end
