require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudIpblockDelete < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud ipblock delete IPBLOCK_ID [IPBLOCK_ID]'

      def initialize(args = [])
        super(args)
        @description =
        'Releases a currently assigned IP block.'
        @directory = 'compute-engine'
        @required_options = [:ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        ipblock_api = Ionoscloud::IPBlocksApi.new(api_client)
        @name_args.each do |ipblock_id|
          begin
            ipblock = ipblock_api.ipblocks_find_by_id(ipblock_id)
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("IP block ID #{ipblock_id} not found. Skipping.")
            next
          end

          print_ipblock(ipblock)

          begin
            confirm('Do you really want to delete this IP block')
          rescue SystemExit
            next
          end

          _, _, headers = ipblock_api.ipblocks_delete_with_http_info(ipblock_id)
          ui.warn("Released IP block #{ipblock.id}. Request ID: #{get_request_id headers}")
        end
      end
    end
  end
end
