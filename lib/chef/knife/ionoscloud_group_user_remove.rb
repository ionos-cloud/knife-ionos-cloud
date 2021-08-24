require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudGroupUserRemove < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud group user remove USER_ID [USER_ID] (options)'

      option :group_id,
              short: '-G GROUP_ID',
              long: '--group-id GROUP_ID',
              description: 'ID of the group.'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Use this operation to remove a user from a group.'
        @required_options = [:group_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        validate_required_params

        user_management_api = Ionoscloud::UserManagementApi.new(api_client)

        request_ids_to_wait = []

        @name_args.each do |user_id|
          begin
            _, _, headers = user_management_api.um_groups_users_delete_with_http_info(
              config[:group_id],
              user_id,
            )
            request_id = get_request_id headers
            request_ids_to_wait.append(request_id)

            ui.warn("Removed User #{user_id} from the Group #{config[:group_id]}. Request ID: #{request_id}.")
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("User ID #{user_id} not found. Skipping.")
            next
          end
        end

        request_ids_to_wait.each { |request_id| api_client.wait_for { is_done? request_id } }

        group = user_management_api.um_groups_find_by_id(
          config[:group_id],
          { depth: 1 },
        )

        users = group.entities.users.items.map! { |el| el.id }

        puts "\n"
        puts "#{ui.color('ID', :cyan)}: #{group.id}"
        puts "#{ui.color('Name', :cyan)}: #{group.properties.name}"
        puts "#{ui.color('Create Datacenter', :cyan)}: #{group.properties.create_data_center.to_s}"
        puts "#{ui.color('Create Snapshot', :cyan)}: #{group.properties.create_snapshot.to_s}"
        puts "#{ui.color('Reserve IP', :cyan)}: #{group.properties.reserve_ip.to_s}"
        puts "#{ui.color('Access Activity Log', :cyan)}: #{group.properties.access_activity_log.to_s}"
        puts "#{ui.color('S3 Privilege', :cyan)}: #{group.properties.s3_privilege.to_s}"
        puts "#{ui.color('Create Backup Unit', :cyan)}: #{group.properties.create_backup_unit.to_s}"
        puts "#{ui.color('Users', :cyan)}: #{users.to_s}"
        puts 'done'
      end
    end
  end
end
