require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudDbaasClusterRestore < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud dbaas cluster restore (options)'

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

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Triggers an in-place restore of the given PostgreSQL.'
        @required_options = [:cluster_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        print "#{ui.color('Restoring Cluster...', :magenta)}"

        restore_request = IonoscloudDbaas::CreateRestoreRequest.new(backup_id: config[:backup_id], recovery_target_time: config[:recovery_target_time])

        IonoscloudDbaas::RestoresApi.new(api_client_dbaas).cluster_restore_post(config[:cluster_id], restore_request)

        puts("\nCluster restored succsefully.")
      end
    end
  end
end
