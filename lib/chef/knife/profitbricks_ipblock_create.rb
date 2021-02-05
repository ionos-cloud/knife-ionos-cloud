require 'chef/knife/ionoscloud_base'

class Chef
  class Knife
    class ProfitbricksIpblockCreate < Knife
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

      def run
        $stdout.sync = true
        validate_required_params(%i(size location), config)

        print "#{ui.color('Allocating IP block...', :magenta)}"

        ipblock_api = Ionoscloud::IPBlocksApi.new(api_client)

        ipblock, _, headers = ipblock_api.ipblocks_post_with_http_info({ properties: { location: config[:location], size: config[:size] } })

        dot = ui.color('.', :magenta)
        api_client.wait_for { print dot; is_done? get_request_id headers }

        puts "\n"
        puts "#{ui.color('ID', :cyan)}: #{ipblock.id}"
        puts "#{ui.color('Location', :cyan)}: #{ipblock.properties.location}"
        puts "#{ui.color('IP Addresses', :cyan)}: #{ipblock.properties.ips}"
        puts 'done'
      end
    end
  end
end
