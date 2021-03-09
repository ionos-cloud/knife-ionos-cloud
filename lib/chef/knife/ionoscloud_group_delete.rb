require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudGroupDelete < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud group delete GROUP_ID [GROUP_ID]'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Use this operation to delete a single group. Resources that are '\
        'assigned to the group are NOT deleted, but are no longer accessible '\
        'to the group members unless the member is a Contract Owner, Admin, or Resource Owner.'
        @required_options = [:ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        validate_required_params(@required_options, config)

        user_management_api = Ionoscloud::UserManagementApi.new(api_client)

        @name_args.each do |group_id|
          begin
            group = user_management_api.um_groups_find_by_id(group_id, { depth: 1 })
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("Group ID #{group_id} not found. Skipping.")
            next
          end

          users = group.entities.users.items.map! { |el| el.id }

          msg_pair('ID', group.id)
          msg_pair('Name', group.properties.name)
          msg_pair('Create Datacenter', group.properties.create_data_center.to_s)
          msg_pair('Create Snapshot', group.properties.create_snapshot.to_s)
          msg_pair('Reserve IP', group.properties.reserve_ip.to_s)
          msg_pair('Access Activity Log', group.properties.access_activity_log.to_s)
          msg_pair('S3 Privilege', group.properties.s3_privilege.to_s)
          msg_pair('Create Backup Unit', group.properties.create_backup_unit.to_s)
          msg_pair('Users', users.to_s)
          puts "\n"

          begin
            confirm('Do you really want to delete this Group')
          rescue SystemExit => exc
            next
          end

          _, _, headers = user_management_api.um_groups_delete_with_http_info(group_id)
          ui.warn("Deleted Group #{group.id}. Request ID: #{get_request_id headers}")
        end
      end
    end
  end
end
