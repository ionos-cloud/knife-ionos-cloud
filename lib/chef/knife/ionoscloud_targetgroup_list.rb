require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudTargetgroupList < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud targetgroup list'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description = 'Lists all available Target Groups.'
        @required_options = [:ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        target_group_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Algorithm', :bold),
          ui.color('Protocol', :bold),
          ui.color('Targets', :bold),
        ]

        target_group_api = Ionoscloud::TargetGroupsApi.new(api_client)

        target_group_api.targetgroups_get({ depth: 1 }).items.each do |target_group|
          target_group_list << target_group.id
          target_group_list << target_group.properties.name
          target_group_list << target_group.properties.algorithm
          target_group_list << target_group.properties.protocol
          target_group_list << target_group.properties.targets.nil? ? 0 : target_group.properties.targets.length
        end

        puts ui.list(target_group_list, :uneven_columns_across, 5)
      end
    end
  end
end
