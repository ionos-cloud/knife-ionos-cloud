require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudBackupunitUpdate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud backupunit update (options)'

      option :backupunit_id,
              short: '-B BACKUPUNIT_ID',
              long: '--backupunit-id BACKUPUNIT_ID',
              description: 'The ID of the Backup unit.'

      option :password,
              short: '-p PASSWORD',
              long: '--password PASSWORD',
              description: 'Alphanumeric password you want assigned to the backup unit'

      option :email,
              long: '--email EMAIL',
              description: 'The e-mail address you want assigned to the backup unit.'

      def initialize(args = [])
        super(args)
        @description =
        'Retrieves information about a backup unit.'
        @directory = 'backup'
        @required_options = [:backupunit_id, :ionoscloud_username, :ionoscloud_password]
        @updatable_fields = [:email, :password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        backupunit_api = Ionoscloud::BackupUnitsApi.new(api_client)

        if @updatable_fields.map { |el| config[el] }.any?
          print "#{ui.color('Updating Backup unit...', :magenta)}"

          backupunit, _, headers  = backupunit_api.backupunits_patch_with_http_info(
            config[:backupunit_id],
            Ionoscloud::BackupUnitProperties.new(
              password: config[:password],
              email: config[:email],
            ),
          )

          dot = ui.color('.', :magenta)
          api_client.wait_for { print dot; is_done? get_request_id headers }
        else
          ui.warn("Nothing to update, please set one of the attributes #{@updatable_fields}.")
        end

        print_backupunit(Ionoscloud::BackupUnitsApi.new(api_client).backupunits_find_by_id(config[:backupunit_id]))
      end
    end
  end
end
