require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudIpblockCreate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud ipblock create (options)'

      option :location,
              short: '-l LOCATION',
              long: '--location LOCATION',
              description: 'Location of the IP block (us/las, us/ewr, de/fra, de/fkb)'

      option :size,
              short: '-S INT',
              long: '--size INT',
              description: 'The number of IP addresses to reserve'

      option :name,
              short: '-n NAME',
              long: '--name NAME',
              description: 'Name of the IP block'

      def initialize(args = [])
        super(args)
        @description =
        'Reserves an IP block at a specified location that can be used by resources '\
        'within any VDCs provisioned in that same location. An IP block consists of '\
        'one or more static IP addresses. The IP block size \(number of IP addresses\) '\
        'and location are required to reserve an IP block.'
        @directory = 'compute-engine'
        @required_options = [:size, :location, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        print "#{ui.color('Allocating IP block...', :magenta)}"

        ipblock, _, headers = Ionoscloud::IPBlocksApi.new(api_client).ipblocks_post_with_http_info(
          Ionoscloud::IpBlock.new(
            properties: Ionoscloud::IpBlockProperties.new(
              location: config[:location],
              size: config[:size],
              name: config[:name],
            ),
          ),
        )

        dot = ui.color('.', :magenta)
        api_client.wait_for { print dot; is_done? get_request_id headers }

        print_ipblock(ipblock)
      end
    end
  end
end
