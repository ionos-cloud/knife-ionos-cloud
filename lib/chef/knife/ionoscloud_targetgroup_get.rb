require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudTargetgroupGet < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud targetgroup get (options)'

      option :target_group_id,
              short: '-T TARGET_GROUP_ID',
              long: '--target-group-id TARGET_GROUP_ID',
              description: 'ID of the Target Group'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Gets information about a Target Group.'
        @required_options = [:target_group_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        validate_required_params(@required_options, config)

        print_target_group(Ionoscloud::TargetGroupsApi.new(api_client).targetgroups_find_by_target_group_id(config[:target_group_id]))
      end
    end
  end
end
