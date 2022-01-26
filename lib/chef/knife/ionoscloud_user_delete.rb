require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudUserDelete < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud user delete USER_ID [USER_ID]'

      def initialize(args = [])
        super(args)
        @description =
        'Blacklists the user, disabling them. The user is not completely purged, '\
        'therefore if you anticipate needing to create a user with the same name '\
        'in the future, we suggest renaming the user before you delete it.'
        @directory = 'user'
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

          print_user(user)
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
