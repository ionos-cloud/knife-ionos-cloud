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

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Use this operation to create a new group and set group privileges.'
        @required_options = [:name, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        validate_required_params(@required_options, config)

        print "#{ui.color('Creating Group...', :magenta)}"

        user_management_api = Ionoscloud::UserManagementApi.new(api_client)

        group, _, headers  = user_management_api.um_groups_post_with_http_info({
          properties: {
            name: config[:name],
            createDataCenter: config[:create_data_center],
            createSnapshot: config[:create_snapshot],
            reserveIp: config[:reserve_ip],
            accessActivityLog: config[:access_activity_log],
            s3Privilege: config[:s3_privilege],
            createBackupUnit: config[:create_backup_unit],
            createK8sCluster: config[:create_k8s_cluster],
            createPcc: config[:create_pcc],
            createInternetAccess: config[:create_internet_access],
          }.compact,
        })

        dot = ui.color('.', :magenta)
        api_client.wait_for { print dot; is_done? get_request_id headers }

        puts "\n"
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
        puts 'done'
      end
    end
  end
end
