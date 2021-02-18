require 'chef/knife/ionoscloud_base'

class Chef
  class Knife
    class IonoscloudIpblockList < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud ipblock list'
      
      attr_reader :description, :required_options
      
      def initialize(args = [])
        super(args)
        @description =
        'Lists all available IP blocks.'
        @required_options = [:ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        validate_required_params(@required_options, config)

        ipblock_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Location', :bold),
          ui.color('IP Addresses', :bold),
        ]
        ipblock_api = Ionoscloud::IPBlocksApi.new(api_client)

        ipblock_api.ipblocks_get({ depth: 1 }).items.each do |ipblock|
          ipblock_list << ipblock.id
          ipblock_list << ipblock.properties.name
          ipblock_list << ipblock.properties.location
          ipblock_list << ipblock.properties.ips.join(", ").to_s
        end

        puts ui.list(ipblock_list, :uneven_columns_across, 4)
      end
    end
  end
end
