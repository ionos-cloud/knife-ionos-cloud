require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudGroupUpdate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud group update (options)'

      option :group_id,
              short: '-G GROUP_ID',
              long: '--group-id GROUP_ID',
              description: 'ID of the group.'

      option :name,
              short: '-N NAME',
              long: '--name NAME',
              description: 'Mame of the group.'

      option :create_data_center,
              short: '-D CREATE_DATACENTER',
              long: '--create-datacenter CREATE_DATACENTER',
              description: 'The group will be allowed to create virtual data centers.'

      option :create_snapshot,
              short: '-s CREATE_SNAPSHOT',
              long: '--create-snapshot CREATE_SNAPSHOT',
              description: 'The group will be allowed to create snapshots.'

      option :reserve_ip,
              short: '-i RESERVE_IP',
              long: '--reserve-ip RESERVE_IP',
              description: 'The group will be allowed to reserve IP addresses.'

      option :access_activity_log,
              short: '-a ACCESS_ACTIVITY_LOG',
              long: '--access-log ACCESS_ACTIVITY_LOG',
              description: 'The group will be allowed to access the activity log.'

      option :s3_privilege,
              long: '--s3 S3_PRIVILEGE',
              description: 'The group will be allowed to manage S3'

      option :create_backup_unit,
              short: '-b CREATE_BACKUPUNIT',
              long: '--create-backupunit CREATE_BACKUPUNIT',
              description: 'The group will be able to manage backup units.'

      option :create_k8s_cluster,
              long: '--create-k8s-cluster CREATE_K8S_CLUSTER',
              description: 'The group will be able to create kubernetes clusters.'

      option :create_pcc,
              long: '--create-pcc CREATE_PCC',
              description: 'The group will be able to manage pccs.'

      option :create_internet_access,
              long: '--create-internet-access CREATE_INTERNET_ACCESS',
              description: 'The group will be have internet access privilege.'

      option :create_flow_log,
              long: '--create-flow-log CREATE_FLOW_LOG',
              description: 'The group will be granted create Flow Logs privilege.'

      option :access_and_manage_monitoring,
              long: '--manage-monitoring ACCESS_AND_MANAGE_MONITORING',
              description: 'Privilege for a group to access and manage monitoring '\
              'related functionality (access metrics, CRUD on alarms, alarm-actions etc) using Monotoring-as-a-Service (MaaS).'

      option :access_and_manage_certificates,
              long: '--manage-certificates ACCESS_AND_MANAGE_CERTIFICATES',
              description: 'Privilege for a group to access and manage certificates.'

      def initialize(args = [])
        super(args)
        @description =
        'Updates information about a Ionoscloud Group.'
        @directory = 'user'
        @required_options = [:group_id, :ionoscloud_username, :ionoscloud_password]
        @updatable_fields = [
          :name, :create_data_center, :create_snapshot, :reserve_ip, :access_activity_log, :s3_privilege,
          :create_backup_unit, :create_k8s_cluster, :create_pcc, :create_internet_access,
          :create_flow_log, :access_and_manage_monitoring, :access_and_manage_certificates,
        ]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        user_management_api = Ionoscloud::UserManagementApi.new(api_client)

        if @updatable_fields.map { |el| config[el] }.any?
          print "#{ui.color('Updating Group...', :magenta)}"

          existing_group = user_management_api.um_groups_find_by_id(config[:group_id], depth: 1)

          group, _, headers = user_management_api.um_groups_put_with_http_info(
            config[:group_id],
            Ionoscloud::Group.new(
              properties: Ionoscloud::GroupProperties.new(
                name: config[:name] || existing_group.properties.name,
                create_data_center: config.key?(:create_data_center) ? config[:create_data_center].to_s != 'false' : existing_group.properties.create_data_center,
                create_snapshot: config.key?(:create_snapshot) ? config[:create_snapshot].to_s != 'false' : existing_group.properties.create_snapshot,
                reserve_ip: config.key?(:reserve_ip) ? config[:reserve_ip].to_s != 'false' : existing_group.properties.reserve_ip,
                access_activity_log: config.key?(:access_activity_log) ? config[:access_activity_log].to_s != 'false' : existing_group.properties.access_activity_log,
                s3_privilege: config.key?(:s3_privilege) ? config[:s3_privilege].to_s != 'false' : existing_group.properties.s3_privilege,
                create_backup_unit: config.key?(:create_backup_unit) ? config[:create_backup_unit].to_s != 'false' : existing_group.properties.create_backup_unit,
                create_k8s_cluster: config.key?(:create_k8s_cluster) ? config[:create_k8s_cluster].to_s != 'false' : existing_group.properties.create_k8s_cluster,
                create_pcc: config.key?(:create_pcc) ? config[:create_pcc].to_s != 'false' : existing_group.properties.create_pcc,
                create_internet_access: config.key?(:create_internet_access) ? config[:create_internet_access].to_s != 'false' : existing_group.properties.create_internet_access,
                create_flow_log: config.key?(:create_flow_log) ? config[:create_flow_log].to_s != 'false' : existing_group.properties.create_flow_log,
                access_and_manage_monitoring: config.key?(:access_and_manage_monitoring) ? config[:access_and_manage_monitoring].to_s != 'false' : existing_group.properties.access_and_manage_monitoring,
                access_and_manage_certificates: config.key?(:access_and_manage_certificates) ? config[:access_and_manage_certificates].to_s != 'false' : existing_group.properties.access_and_manage_certificates,
              ),
            ),
          )

          dot = ui.color('.', :magenta)
          api_client.wait_for { print dot; is_done? get_request_id headers }
        else
          ui.warn("Nothing to update, please set one of the attributes #{@updatable_fields}.")
        end

        print_group(user_management_api.um_groups_find_by_id(config[:group_id], depth: 1))
      end
    end
  end
end
