require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudGroupDelete < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud group delete GROUP_ID [GROUP_ID]'

      def initialize(args = [])
        super(args)
        @description =
        'Use this operation to delete a single group. Resources that are '\
        'assigned to the group are NOT deleted, but are no longer accessible '\
        'to the group members unless the member is a Contract Owner, Admin, or Resource Owner.'
        @directory = 'user'
        @required_options = [:ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
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

          print_group(group)
          puts "\n"

          begin
            confirm('Do you really want to delete this Group')
          rescue SystemExit
            next
          end

          _, _, headers = user_management_api.um_groups_delete_with_http_info(group_id)
          ui.warn("Deleted Group #{group.id}. Request ID: #{get_request_id headers}")
        end
      end
    end
  end
end
