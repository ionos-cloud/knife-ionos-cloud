require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudGroupList < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud group list (options)'

      option :user_id,
              short: '-u USER_ID',
              long: '--user-id USER_ID',
              description: 'ID of the user.'

      attr_reader :description, :required_options
      
      def initialize(args = [])
        super(args)
        @description =
        'This retrieves a full list of all groups.'
        @required_options = [:ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        validate_required_params(@required_options, config)

        group_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Create Datacenter', :bold),
          ui.color('Create Snapshot', :bold),
          ui.color('Reserve IP', :bold),
          ui.color('Access Activity Log', :bold),
          ui.color('S3 Privilege', :bold),
          ui.color('Create Backup Unit', :bold),
        ]

        user_management_api = Ionoscloud::UserManagementApi.new(api_client)

        if config[:group_id]
          groups = user_management_api.um_users_groups_get(config[:user], { depth: 1 }).items
        else
          groups = user_management_api.um_groups_get({ depth: 1 }).items
        end

        groups.each do |group|
          group_list << group.id
          group_list << group.properties.name
          group_list << group.properties.create_data_center.to_s
          group_list << group.properties.create_snapshot.to_s
          group_list << group.properties.reserve_ip.to_s
          group_list << group.properties.access_activity_log.to_s
          group_list << group.properties.s3_privilege.to_s
          group_list << group.properties.create_backup_unit.to_s
        end

        puts ui.list(group_list, :uneven_columns_across, 8)
      end
    end
  end
end
