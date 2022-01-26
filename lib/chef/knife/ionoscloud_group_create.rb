require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudGroupCreate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud group create (options)'

      option :name,
              short: '-N NAME',
              long: '--name NAME',
              description: 'Mame of the group.'

      option :create_data_center,
              short: '-D',
              long: '--create-datacenter',
              description: 'The group will be allowed to create virtual data centers.'

      option :create_snapshot,
              short: '-s',
              long: '--create-snapshot',
              description: 'The group will be allowed to create snapshots.'

      option :reserve_ip,
              short: '-i',
              long: '--reserve-ip',
              description: 'The group will be allowed to reserve IP addresses.'

      option :access_activity_log,
              short: '-a',
              long: '--access-log',
              description: 'The group will be allowed to access the activity log.'

      option :s3_privilege,
              long: '--s3',
              description: 'The group will be allowed to manage S3'

      option :create_backup_unit,
              short: '-b',
              long: '--create-backupunit',
              description: 'The group will be able to manage backup units.'

      option :create_k8s_cluster,
              long: '--create-k8s-cluster',
              description: 'The group will be able to create kubernetes clusters.'

      option :create_pcc,
              long: '--create-pcc',
              description: 'The group will be able to manage pccs.'

      option :create_internet_access,
              long: '--create-internet-access',
              description: 'The group will be have internet access privilege.'

      option :create_flow_log,
              long: '--create-flow-log',
              description: 'The group will be granted create Flow Logs privilege.'

      option :access_and_manage_monitoring,
              long: '--manage-monitoring',
              description: 'Privilege for a group to access and manage monitoring '\
              'related functionality (access metrics, CRUD on alarms, alarm-actions etc) using Monotoring-as-a-Service (MaaS).'

      option :access_and_manage_certificates,
              long: '--manage-certificates',
              description: 'Privilege for a group to access and manage certificates.'

      def initialize(args = [])
        super(args)
        @description =
        'Use this operation to create a new group and set group privileges.'
        @directory = 'user'
        @required_options = [:name, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        print "#{ui.color('Creating Group...', :magenta)}"

        user_management_api = Ionoscloud::UserManagementApi.new(api_client)

        group_properties = {
          name: config[:name],
          create_data_center: config[:create_data_center],
          create_snapshot: config[:create_snapshot],
          reserve_ip: config[:reserve_ip],
          access_activity_log: config[:access_activity_log],
          s3_privilege: config[:s3_privilege],
          create_backup_unit: config[:create_backup_unit],
          create_k8s_cluster: config[:create_k8s_cluster],
          create_pcc: config[:create_pcc],
          create_internet_access: config[:create_internet_access],
          create_flow_log: config[:create_flow_log],
          access_and_manage_monitoring: config[:access_and_manage_monitoring],
          access_and_manage_certificates: config[:access_and_manage_certificates],
        }.compact

        group, _, headers  = user_management_api.um_groups_post_with_http_info(
          Ionoscloud::Group.new(properties: Ionoscloud::GroupProperties.new(**group_properties)),
        )

        dot = ui.color('.', :magenta)
        api_client.wait_for { print dot; is_done? get_request_id headers }

        print_group(group)
      end
    end
  end
end
