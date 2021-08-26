require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudBackupunitList < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud backupunit list'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Retrieve a list of all the backup units the supplied credentials have access to.'
        @required_options = [:ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        backupunit_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Email', :bold),
        ]

        backupunit_api = Ionoscloud::BackupUnitApi.new(api_client)

        backupunit_api.backupunits_get({ depth: 1 }).items.each do |backupunit|
          backupunit_list << backupunit.id
          backupunit_list << backupunit.properties.name
          backupunit_list << backupunit.properties.email
        end

        puts ui.list(backupunit_list, :uneven_columns_across, 3)
      end
    end
  end
end
