require 'chef/knife/ionoscloud_base'

class Chef
  class Knife
    class IonoscloudIpblockList < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud ipblock list'

      def run
        $stdout.sync = true
        ipblock_list = [
          ui.color('ID', :bold),
          ui.color('Location', :bold),
          ui.color('IP Addresses', :bold),
        ]
        ipblock_api = Ionoscloud::IPBlocksApi.new(api_client)

        ipblock_api.ipblocks_get({ depth: 1 }).items.each do |ipblock|
          ipblock_list << ipblock.id
          ipblock_list << ipblock.properties.location
          ipblock_list << ipblock.properties.ips.join(", ").to_s
        end

        puts ui.list(ipblock_list, :uneven_columns_across, 3)
      end
    end
  end
end
