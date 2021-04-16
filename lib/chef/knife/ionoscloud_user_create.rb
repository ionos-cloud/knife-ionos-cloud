require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudUserCreate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud user create (options)'

      option :firstname,
              short: '-f FIRSTNAME',
              long: '--firstname FIRSTNAME',
              description: 'Firstname of the user.'

      option :lastname,
              short: '-l LASTNAME',
              long: '--lastname LASTNAME',
              description: 'Lastname of the user.'

      option :email,
              short: '-e EMAIL',
              long: '--email EMAIL',
              description: 'An e-mail address for the user.'

      option :password,
              short: '-p PASSWORD',
              long: '--password PASSWORD',
              description: 'A password for the user.'

      option :administrator,
              short: '-a ADMIN',
              long: '--admin ADMIN',
              description: 'Assigns the user have administrative rights.'

      option :force_sec_auth,
              long: '--sec-auth',
              description: 'Indicates if secure (two-factor) authentication should be forced for the user.'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        "Creates a new user under a particular contract.\n**Please Note**: The password set "\
        "here cannot be updated through the API currently. It is recommended that a new user "\
        "log into the DCD and change their password."
        @required_options = [:firstname, :lastname, :email, :password, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        validate_required_params(@required_options, config)

        print "#{ui.color('Creating user...', :magenta)}"

        user_management_api = Ionoscloud::UserManagementApi.new(api_client)

        user, _, headers  = user_management_api.um_users_post_with_http_info({
          properties: {
            firstname: config[:firstname],
            lastname: config[:lastname],
            email: config[:email],
            password: config[:password],
            administrator: config[:administrator],
            forceSecAuth: config[:force_sec_auth],
          }.compact,
        })

        dot = ui.color('.', :magenta)
        api_client.wait_for { print dot; is_done? get_request_id headers }

        puts "\n"
        puts "#{ui.color('ID', :cyan)}: #{user.id}"
        puts "#{ui.color('Firstname', :cyan)}: #{user.properties.firstname}"
        puts "#{ui.color('Lastname', :cyan)}: #{user.properties.lastname}"
        puts "#{ui.color('Email', :cyan)}: #{user.properties.email}"
        puts "#{ui.color('Administrator', :cyan)}: #{user.properties.administrator.to_s}"
        puts "#{ui.color('2-Factor Auth', :cyan)}: #{user.properties.force_sec_auth.to_s}"
        puts 'done'
      end
    end
  end
end
