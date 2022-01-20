require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudUserGet < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud user get (options)'

      option :user_id,
              short: '-U USER_ID',
              long: '--user-id USER_ID',
              description: 'ID of the group.'

      def initialize(args = [])
        super(args)
        @description =
        'Retrieves the attributes of a given Ionoscloud User.'
        @directory = 'user'
        @required_options = [:user_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)
        print_user(Ionoscloud::UserManagementApi.new(api_client).um_users_find_by_id(config[:user_id]))
      end
    end
  end
end
