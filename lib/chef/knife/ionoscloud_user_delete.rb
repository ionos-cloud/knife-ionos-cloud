require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudUserDelete < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud user delete USER_ID [USER_ID]'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Blacklists the user, disabling them. The user is not completely purged, '\
        'therefore if you anticipate needing to create a user with the same name '\
        'in the future, we suggest renaming the user before you delete it.'
        @required_options = [:ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        user_management_api = Ionoscloud::UserManagementApi.new(api_client)

        @name_args.each do |user_id|
          begin
            user = user_management_api.um_users_find_by_id(user_id)
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("User ID #{user_id} not found. Skipping.")
            next
          end

          msg_pair('ID', user.id)
          msg_pair('Firstname', user.properties.firstname)
          msg_pair('Lastname', user.properties.lastname)
          msg_pair('Email', user.properties.email)
          msg_pair('Administrator', user.properties.administrator.to_s)
          msg_pair('2-Factor Auth', user.properties.force_sec_auth.to_s)
          puts "\n"

          begin
            confirm('Do you really want to delete this User')
          rescue SystemExit => exc
            next
          end

          _, _, headers = user_management_api.um_users_delete_with_http_info(user_id)
          ui.warn("Deleted User #{user.id}. Request ID: #{get_request_id headers}")
        end
      end
    end
  end
end
