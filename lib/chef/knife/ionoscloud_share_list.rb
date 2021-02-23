require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudShareList < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud share list (options)'

      option :group_id,
              short: '-G GROUP_ID',
              long: '--group-id GROUP_ID',
              description: 'ID of the group.'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Retrieves a full list of all the resources that are shared through this '\
        'group and lists the permissions granted to the group members for each shared resource.'
        @required_options = [:group_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        validate_required_params(@required_options, config)

        share_list = [
          ui.color('ID', :bold),
          ui.color('Edit Privilege', :bold),
          ui.color('Share Privilege', :bold),
        ]

        user_management_api = Ionoscloud::UserManagementApi.new(api_client)

        user_management_api.um_groups_shares_get(config[:group_id], { depth: 1 }).items.each do |share|
          share_list << share.id
          share_list << share.properties.edit_privilege.to_s
          share_list << share.properties.share_privilege.to_s
        end

        puts ui.list(share_list, :uneven_columns_across, 3)
      end
    end
  end
end
