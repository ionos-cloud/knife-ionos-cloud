require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudUserList < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud user list (options)'

      option :group_id,
              short: '-g GROUP_ID',
              long: '--group-id GROUP_ID',
              description: 'ID of the group.'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Retrieve a list of all the users that have been created under a contract. '\
        'You can retrieve a list of users who are members of the group by passing the '\
        '*group_id* option.'
        @required_options = [:ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        validate_required_params(@required_options, config)

        user_list = [
          ui.color('ID', :bold),
          ui.color('Firstname', :bold),
          ui.color('Lastname', :bold),
          ui.color('Email', :bold),
          ui.color('Administrator', :bold),
          ui.color('2-Factor Auth', :bold),
        ]

        user_management_api = Ionoscloud::UserManagementApi.new(api_client)

        if config[:group_id]
          users = user_management_api.um_groups_users_get(config[:group_id], { depth: 1 }).items
        else
          users = user_management_api.um_users_get({ depth: 1 }).items
        end

        users.each do |user|
          user_list << user.id
          user_list << user.properties.firstname
          user_list << user.properties.lastname
          user_list << user.properties.email
          user_list << user.properties.administrator.to_s
          user_list << user.properties.force_sec_auth.to_s
        end

        puts ui.list(user_list, :uneven_columns_across, 6)
      end
    end
  end
end
