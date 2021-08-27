require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudIpblockGet < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud ipblock get (options)'

      option :ipblock_id,
              short: '-I IPBLOCK_ID',
              long: '--ipblock-id IPBLOCK_ID',
              description: 'ID of the IPBlock.'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Retrieves information about an IP Block.'
        @required_options = [:ipblock_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        print_ipblock(Ionoscloud::IPBlocksApi.new(api_client).ipblocks_find_by_id(config[:ipblock_id]))
      end
    end
  end
end
