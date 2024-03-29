require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudBackupunitSsourl < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud backupunit ssourl (options)'

      option :backupunit_id,
              short: '-B BACKUPUNIT_ID',
              long: '--backupunit-id BACKUPUNIT_ID',
              description: 'The ID of the Backup unit.'

      def initialize(args = [])
        super(args)
        @description =
        'The ProfitBricks backup system features a web-based GUI. Once you have created '\
        'a backup unit, you can access the GUI with a Single Sign On \(SSO\) URL that can be '\
        'retrieved from the Cloud API using this request.'
        @directory = 'backup'
        @required_options = [:backupunit_id]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        begin
          puts Ionoscloud::BackupUnitsApi.new(api_client).backupunits_ssourl_get(config[:backupunit_id]).sso_url
        rescue Ionoscloud::ApiError => err
          raise err unless err.code == 404
          ui.error("Backup unit ID #{config[:backupunit_id]} not found.")
        end
      end
    end
  end
end
