require 'chef/knife/profitbricks_base'

class Chef
  class Knife
    class ProfitbricksIpblockCreate < Knife
      include Knife::ProfitbricksBase

      banner 'knife profitbricks ipblock create (options)'

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

        ipblock, _, headers = ipblock_api.ipblocks_post_with_http_info({properties: {location: config[:location], size: config[:size]}})

        request_id = headers['Location'].scan(%r{/requests/(\b[0-9a-f]{8}\b-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-\b[0-9a-f]{12}\b)}).last.first

        dot = ui.color('.', :magenta)
        api_client.wait_for { print dot; is_done? request_id }

        puts "\n"
        puts "#{ui.color('ID', :cyan)}: #{ipblock.id}"
        puts "#{ui.color('Location', :cyan)}: #{ipblock.properties.location}"
        puts "#{ui.color('IP Addresses', :cyan)}: #{ipblock.properties.ips}"
        @ipid = ipblock.id
        puts 'done'
      end
    end
  end
end
