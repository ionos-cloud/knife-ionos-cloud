require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudUserUpdate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud user update (options)'

      option :user_id,
              short: '-U USER_ID',
              long: '--user-id USER_ID',
              description: 'ID of the User.'

      option :firstname,
              short: '-f FIRSTNAME',
              long: '--firstname FIRSTNAME',
              description: 'Firstname of the user.'

      option :lastname,
              short: '-l LASTNAME',
              long: '--lastname LASTNAME',
              description: 'Lastname of the user.'

      option :email,
              long: '--email EMAIL',
              description: 'An e-mail address for the user.'

      option :administrator,
              short: '-a ADMIN',
              long: '--admin ADMIN',
              description: 'Assigns the user have administrative rights.'

      option :force_sec_auth,
              long: '--sec-auth FORCE_SEC_AUTH',
              description: 'Indicates if secure (two-factor) authentication should be forced for the user.'

      option :sec_auth_active,
              long: '--sec-auth SEC_AUTH_ACTIVE',
              description: 'Indicates if secure authentication is active for the user or not.'

      option :active,
              long: '--active ACTIVE',
              description: 'Indicates if the user is active.'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Updates information about a Ionoscloud User.'
        @required_options = [:user_id, :ionoscloud_username, :ionoscloud_password]
        @updatable_fields = [:firstname, :lastname, :email, :administrator, :force_sec_auth, :sec_auth_active, :active]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        user_management_api = Ionoscloud::UserManagementApi.new(api_client)

        if @updatable_fields.map { |el| config[el] }.any?
          print "#{ui.color('Updating User...', :magenta)}"

          user = user_management_api.um_users_find_by_id(config[:user_id])

          new_user = Ionoscloud::UserPut.new(
            properties: Ionoscloud::UserPropertiesPut.new(
              firstname: config[:firstname] || user.properties.firstname,
              lastname: config[:lastname] || user.properties.lastname,
              email: config[:email] || user.properties.email,
              administrator: (config.key?(:administrator) ? config[:administrator].to_s.downcase == 'true' : user.properties.administrator),
              force_sec_auth: (config.key?(:force_sec_auth) ? config[:force_sec_auth].to_s.downcase == 'true' : user.properties.force_sec_auth),
              sec_auth_active: (config.key?(:sec_auth_active) ? config[:sec_auth_active].to_s.downcase == 'true' : user.properties.sec_auth_active),
              active: (config.key?(:active) ? config[:active].to_s.downcase == 'true' : user.properties.active),
            ),
          )

          _, _, headers  = user_management_api.um_users_put_with_http_info(config[:user_id], new_user)

          dot = ui.color('.', :magenta)
          api_client.wait_for { print dot; is_done? get_request_id headers }
        else
          ui.warn("Nothing to update, please set one of the attributes #{@updatable_fields}.")
        end

        print_user(user_management_api.um_users_find_by_id(config[:user_id]))
      end
    end
  end
end
