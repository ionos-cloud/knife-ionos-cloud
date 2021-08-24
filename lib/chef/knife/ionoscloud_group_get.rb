require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudGroupGet < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud group get (options)'

      option :group_id,
              short: '-G GROUP_ID',
              long: '--group-id GROUP_ID',
              description: 'ID of the group.'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Retrieves detailed information about a specific group. This will also '\
        'retrieve a list of users who are members of the group.'
        @required_options = [:group_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        validate_required_params

        user_management_api = Ionoscloud::UserManagementApi.new(api_client)
        group = user_management_api.um_groups_find_by_id(config[:group_id], { depth: 1 })

        users = group.entities.users.items.map! { |el| el.id }

        puts "#{ui.color('ID', :cyan)}: #{group.id}"
        puts "#{ui.color('Name', :cyan)}: #{group.properties.name}"
        puts "#{ui.color('Create Datacenter', :cyan)}: #{group.properties.create_data_center.to_s}"
        puts "#{ui.color('Create Snapshot', :cyan)}: #{group.properties.create_snapshot.to_s}"
        puts "#{ui.color('Reserve IP', :cyan)}: #{group.properties.reserve_ip.to_s}"
        puts "#{ui.color('Access Activity Log', :cyan)}: #{group.properties.access_activity_log.to_s}"
        puts "#{ui.color('S3 Privilege', :cyan)}: #{group.properties.s3_privilege.to_s}"
        puts "#{ui.color('Create Backup Unit', :cyan)}: #{group.properties.create_backup_unit.to_s}"
        puts "#{ui.color('Create K8s Clusters', :cyan)}: #{group.properties.create_k8s_cluster.to_s}"
        puts "#{ui.color('Create PCC', :cyan)}: #{group.properties.create_pcc.to_s}"
        puts "#{ui.color('Create Internet Acess', :cyan)}: #{group.properties.create_internet_access.to_s}"
        puts "#{ui.color('Create Flow Logs', :cyan)}: #{group.properties.create_flow_log.to_s}"
        puts "#{ui.color('Access and Manage Monitoring', :cyan)}: #{group.properties.access_and_manage_monitoring.to_s}"
        puts "#{ui.color('Access and Manage Certificates', :cyan)}: #{group.properties.access_and_manage_certificates.to_s}"
        puts "#{ui.color('Users', :cyan)}: #{users.to_s}"
      end
    end
  end
end
