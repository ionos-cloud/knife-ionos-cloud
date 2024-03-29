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

      def initialize(args = [])
        super(args)
        @description =
        'This retrieves a full list of all groups.'
        @directory = 'user'
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        group_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Datacenter', :bold),
          ui.color('Snapshot', :bold),
          ui.color('IP', :bold),
          ui.color('Activity', :bold),
          ui.color('S3', :bold),
          ui.color('Backup', :bold),
          ui.color('K8s', :bold),
          ui.color('PCC', :bold),
          ui.color('Internet', :bold),
          ui.color('FlowLogs', :bold),
          ui.color('Monitoring', :bold),
          ui.color('Certificates', :bold),
        ]

        user_management_api = Ionoscloud::UserManagementApi.new(api_client)

        if config[:user_id]
          groups = user_management_api.um_users_groups_get(config[:user_id], { depth: 1 }).items
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
          group_list << group.properties.create_k8s_cluster.to_s
          group_list << group.properties.create_pcc.to_s
          group_list << group.properties.create_internet_access.to_s
          group_list << group.properties.create_flow_log.to_s
          group_list << group.properties.access_and_manage_monitoring.to_s
          group_list << group.properties.access_and_manage_certificates.to_s
        end

        puts ui.list(group_list, :uneven_columns_across, 14)
      end
    end
  end
end
