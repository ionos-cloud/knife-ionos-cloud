require 'chef/knife/ionoscloud_base'

class Chef
  class Knife
    class IonoscloudIpblockDelete < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud ipblock delete IPBLOCK_ID [IPBLOCK_ID]'
      
      attr_reader :description, :required_options
      
      def initialize(args=[])
        super(args)
        @description =
        'Releases a currently assigned IP block.'
        @required_options = []
      end

      def run
        ipblock_api = Ionoscloud::IPBlocksApi.new(api_client)
        @name_args.each do |ipblock_id|
          begin
            ipblock = ipblock_api.ipblocks_find_by_id(ipblock_id)
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("IP block ID #{ipblock_id} not found. Skipping.")
            next
          end

          msg_pair('ID', ipblock.id)
          msg_pair('Name', ipblock.properties.name)
          msg_pair('Location', ipblock.properties.location)
          msg_pair('IP Addresses', ipblock.properties.ips)

          begin
            confirm('Do you really want to delete this IP block')
          rescue SystemExit => exc
            next
          end

          _, _, headers = ipblock_api.ipblocks_delete_with_http_info(ipblock_id)
          ui.warn("Released IP block #{ipblock.id}. Request ID: #{get_request_id headers}")
        end
      end
    end
  end
end
