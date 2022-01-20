require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudShareGet < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud share get (options)'

      option :group_id,
              short: '-G GROUP_ID',
              long: '--group-id GROUP_ID',
              description: 'ID of the group.'

      option :resource_id,
              short: '-R RESOURCE_ID',
              long: '--resource-id RESOURCE_ID',
              description: 'The ID of the resource.'

      def initialize(args = [])
        super(args)
        @description =
        'Retrieves the attributes of a given Group Share.'
        @directory = 'user'
        @required_options = [:group_id, :resource_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        print_share(Ionoscloud::UserManagementApi.new(api_client).um_groups_shares_find_by_resource_id(config[:group_id], config[:resource_id]))
      end
    end
  end
end
