require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudShareCreate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud share create (options)'

      option :group_id,
              short: '-G GROUP_ID',
              long: '--group-id GROUP_ID',
              description: 'ID of the group.'

      option :resource_id,
              short: '-R RESOURCE_ID',
              long: '--resource-id RESOURCE_ID',
              description: 'The ID of the resource.'

      option :edit_privilege,
              long: '--edit',
              description: 'The group has permission to edit privileges on this resource.'

      option :share_privilege,
              short: '-s',
              long: '--share',
              description: 'The group has permission to share this resource.'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Adds a specific resource share to a group and optionally allows the setting of permissions '\
        'for that resource. As an example, you might use this to grant permissions to use an image '\
        'or snapshot to a specific group.'
        @required_options = [:group_id, :resource_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        print "#{ui.color('Sharing Resource...', :magenta)}"

        user_management_api = Ionoscloud::UserManagementApi.new(api_client)

        share, _, headers  = user_management_api.um_groups_shares_post_with_http_info(
          config[:group_id],
          config[:resource_id],
          Ionoscloud::GroupShare.new(
            properties: Ionoscloud::GroupShareProperties.new(
              edit_privilege: config[:edit_privilege],
              share_privilege: config[:share_privilege],
            ),
          ),
        )

        dot = ui.color('.', :magenta)
        api_client.wait_for { print dot; is_done? get_request_id headers }

        print_share(share)
      end
    end
  end
end
