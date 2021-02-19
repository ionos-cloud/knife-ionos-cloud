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

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'The ProfitBricks backup system features a web-based GUI. Once you have created '\
        'a backup unit, you can access the GUI with a Single Sign On (SSO) URL that can be '\
        'retrieved from the Cloud API using this request.'
        @required_options = [:backupunit_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        validate_required_params(@required_options, config)

        puts Ionoscloud::BackupUnitApi.new(api_client).backupunits_ssourl_get(config[:backupunit_id]).sso_url
      end
    end
  end
end
