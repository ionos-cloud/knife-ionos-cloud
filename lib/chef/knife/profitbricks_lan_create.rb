require 'chef/knife/profitbricks_base'

class Chef
  class Knife
    class ProfitbricksLanCreate < Knife
      include Knife::ProfitbricksBase

      banner 'knife profitbricks lan create (options)'

      option :datacenter_id,
             short: '-D DATACENTER_ID',
             long: '--datacenter-id DATACENTER_ID',
             description: 'Name of the data center'

      option :name,
             short: '-n NAME',
             long: '--name NAME',
             description: 'Name of the server'

      option :public,
             short: '-p',
             long: '--public',
             boolean: true,
             default: false,
             description: 'Boolean indicating if the LAN faces the public ' \
                          'Internet or not; defaults to false'


      def run
        $stdout.sync = true
        validate_required_params(%i(datacenter_id), config)

        print "#{ui.color('Creating LAN...', :magenta)}"

        lan_api = Ionoscloud::LanApi.new(api_client)

        lan, _, headers = lan_api.datacenters_lans_post_with_http_info(
          config[:datacenter_id], 
          {
            properties: {
              name: config[:name], 
              public: config[:public],
            }
          },
        )

        request_id = headers['Location'].scan(%r{/requests/(\b[0-9a-f]{8}\b-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-\b[0-9a-f]{12}\b)}).last.first

        dot = ui.color('.', :magenta)
        api_client.wait_for { print dot; is_done? request_id }

        lan = lan_api.datacenters_lans_find_by_id(config[:datacenter_id], lan.id)

        puts "\n"
        puts "#{ui.color('ID', :cyan)}: #{lan.id}"
        puts "#{ui.color('Name', :cyan)}: #{lan.properties.name}"
        puts "#{ui.color('Public', :cyan)}: #{lan.properties.public}"

        puts 'done'
      end
    end
  end
end
