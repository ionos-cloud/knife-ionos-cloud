require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudBackupunitDelete < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud backupunit delete BACKUPUNIT_ID [BACKUPUNIT_ID]'

      def initialize(args = [])
        super(args)
        @description =
        'A backup unit may be deleted using a DELETE request. Deleting a backup unit '\
        'is a dangerous operation. A successful DELETE request will remove the backup '\
        'plans inside a backup unit, ALL backups associated with the backup unit, the '\
        'backup user and finally the backup unit itself.'
        @directory = 'backup'
        @required_options = [:ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        backupunit_api = Ionoscloud::BackupUnitsApi.new(api_client)

        @name_args.each do |backupunit_id|
          begin
            backupunit = backupunit_api.backupunits_find_by_id(backupunit_id)
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("Backup unit ID #{backupunit_id} not found. Skipping.")
            next
          end

          print_backupunit(backupunit)
          puts "\n"

          begin
            confirm('Do you really want to delete this Backup unit')
          rescue SystemExit => exc
            next
          end

          _, _, headers = backupunit_api.backupunits_delete_with_http_info(backupunit_id)
          ui.warn("Deleted Backup unit #{backupunit.id}. Request ID: #{get_request_id headers}")
        end
      end
    end
  end
end
