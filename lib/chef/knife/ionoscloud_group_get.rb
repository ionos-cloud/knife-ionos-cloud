require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudGroupGet < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud group get (options)'

      option :group_id,
              short: '-G GROUP_ID',
              long: '--group-id GROUP_ID',
              description: 'ID of the group.'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Retrieves detailed information about a specific group. This will also '\
        'retrieve a list of users who are members of the group.'
        @required_options = [:group_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        user_management_api = Ionoscloud::UserManagementApi.new(api_client)
        group = user_management_api.um_groups_find_by_id(config[:group_id], { depth: 1 })

        print_group(group)
      end
    end
  end
end
