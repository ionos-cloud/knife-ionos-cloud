require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudShareDelete < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud server delete SHARE_ID [SHARE_ID] (options)'

      option :group_id,
              short: '-G GROUP_ID',
              long: '--group-id GROUP_ID',
              description: 'ID of the group.'

      def initialize(args = [])
        super(args)
        @description =
        'Removes a resource share from a specified group.'
        @directory = 'user'
        @required_options = [:group_id]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        user_management_api = Ionoscloud::UserManagementApi.new(api_client)

        @name_args.each do |share_id|
          begin
            share = user_management_api.um_groups_shares_find_by_resource_id(config[:group_id], share_id)
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("Resource Share ID #{share_id} not found. Skipping.")
            next
          end

          print_share(share)
          puts "\n"

          begin
            confirm('Do you really want to delete this Resource Share')
          rescue SystemExit
            next
          end

          _, _, headers = user_management_api.um_groups_shares_delete_with_http_info(config[:group_id], share_id)
          ui.warn("Deleted Resource Share #{share.id}. Request ID: #{get_request_id headers}")
        end
      end
    end
  end
end
