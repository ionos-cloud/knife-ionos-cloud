require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudShareUpdate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud share update (options)'

      option :group_id,
              short: '-G GROUP_ID',
              long: '--group-id GROUP_ID',
              description: 'ID of the group.'

      option :resource_id,
              short: '-R RESOURCE_ID',
              long: '--resource-id RESOURCE_ID',
              description: 'The ID of the resource.'

      option :edit_privilege,
              long: '--edit EDIT_PRIVILEGE',
              description: 'The group has permission to edit privileges on this resource.'

      option :share_privilege,
              short: '-s SHARE_PRIVILEGE',
              long: '--share SHARE_PRIVILEGE',
              description: 'The group has permission to share this resource.'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Updates information about a Ionoscloud Group Share.'
        @required_options = [:group_id, :resource_id, :ionoscloud_username, :ionoscloud_password]
        @updatable_fields = [:edit_privilege, :share_privilege]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        user_management_api = Ionoscloud::UserManagementApi.new(api_client)

        if @updatable_fields.map { |el| config[el] }.any?
          print "#{ui.color('Updating Group Share...', :magenta)}"

          share = user_management_api.um_groups_shares_find_by_resource_id(config[:group_id], config[:resource_id])

          new_share = Ionoscloud::GroupShare.new(
            properties: Ionoscloud::GroupShareProperties.new(
              edit_privilege: (config.key?(:edit_privilege) ? config[:edit_privilege].to_s.downcase == 'true' : share.properties.edit_privilege),
              share_privilege: (config.key?(:share_privilege) ? config[:share_privilege].to_s.downcase == 'true' : share.properties.share_privilege),
            ),
          )

          user_management_api.um_groups_shares_put_with_http_info(config[:group_id], config[:resource_id], new_share)
        else
          ui.warn("Nothing to update, please set one of the attributes #{@updatable_fields}.")
        end

        print_share(user_management_api.um_groups_shares_find_by_resource_id(config[:group_id], config[:resource_id]))
      end
    end
  end
end
