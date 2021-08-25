require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudBackupunitGet < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud backupunit get (options)'

      option :backupunit_id,
              short: '-B BACKUPUNIT_ID',
              long: '--backupunit-id BACKUPUNIT_ID',
              description: 'The ID of the Backup unit.'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Retrieves information about a backup unit.'
        @required_options = [:backupunit_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        print_backupunit(Ionoscloud::BackupUnitApi.new(api_client).backupunits_find_by_id(config[:backupunit_id]))
      end
    end
  end
end
