require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudBackupunitCreate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud backupunit create (options)'

      option :name,
              short: '-n NAME',
              long: '--name NAME',
              description: 'Alphanumeric name you want assigned to the backup unit'

      option :password,
              short: '-p PASSWORD',
              long: '--password PASSWORD',
              description: 'Alphanumeric password you want assigned to the backup unit'

      option :email,
              short: '-e EMAIL',
              long: '--email EMAIL',
              description: 'The e-mail address you want assigned to the backup unit.'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Create a new backup unit.'
        @required_options = [:name, :password, :email, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        print "#{ui.color('Creating Backup unit...', :magenta)}"

        backupunit_api = Ionoscloud::BackupUnitsApi.new(api_client)

        backupunit, _, headers  = backupunit_api.backupunits_post_with_http_info({
          properties: {
            name: config[:name],
            password: config[:password],
            email: config[:email],
          }.compact,
        })

        dot = ui.color('.', :magenta)
        api_client.wait_for { print dot; is_done? get_request_id headers }

        puts backupunit

        puts "\n"
        puts "#{ui.color('ID', :cyan)}: #{backupunit.id}"
        puts "#{ui.color('Name', :cyan)}: #{backupunit.properties.name}"
        puts "#{ui.color('Email', :cyan)}: #{backupunit.properties.email}"
        puts 'done'
      end
    end
  end
end
