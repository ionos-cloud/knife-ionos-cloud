require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudLanGet < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud lan get (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'ID of the data center'

      option :lan_id,
              short: '-L LAN_ID',
              long: '--lan-id LAN_ID',
              description: 'ID of the LAN'

      def initialize(args = [])
        super(args)
        @description =
        'Retrieves information about a Ionoscloud LAN.'
        @directory = 'compute-engine'
        @required_options = [:datacenter_id, :lan_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        print_lan(Ionoscloud::LANsApi.new(api_client).datacenters_lans_find_by_id(config[:datacenter_id], config[:lan_id]))
      end
    end
  end
end
