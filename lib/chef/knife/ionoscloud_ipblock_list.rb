require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudIpblockList < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud ipblock list'

      def initialize(args = [])
        super(args)
        @description =
        'Lists all available IP blocks.'
        @directory = 'compute-engine'
        @required_options = [:ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        ipblock_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Location', :bold),
          ui.color('IP Addresses', :bold),
          ui.color('IP Consumers count', :bold),
        ]
        ipblock_api = Ionoscloud::IPBlocksApi.new(api_client)

        ipblock_api.ipblocks_get({ depth: 1 }).items.each do |ipblock|
          ipblock_list << ipblock.id
          ipblock_list << ipblock.properties.name
          ipblock_list << ipblock.properties.location
          ipblock_list << ipblock.properties.ips.join(', ')
          ipblock_list << ipblock.properties.ip_consumers.nil? ? 0 : ipblock.properties.ip_consumers.length
        end

        puts ui.list(ipblock_list, :uneven_columns_across, 5)
      end
    end
  end
end
