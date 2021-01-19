require 'chef/knife/profitbricks_base'

class Chef
  class Knife
    class ProfitbricksDatacenterCreate < Knife
      include Knife::ProfitbricksBase

      banner 'knife profitbricks datacenter create (options)'

      option :name,
             short: '-n NAME',
             long: '--name NAME',
             description: 'Name of the data center'

      option :description,
             short: '-D DESCRIPTION',
             long: '--description DESCRIPTION',
             description: 'Description of the data center'

      option :location,
             short: '-l LOCATION',
             long: '--location LOCATION',
             description: 'Location of the data center'

      def run
        $stdout.sync = true

        validate_required_params(%i(name location), Chef::Config[:knife])

        print "#{ui.color('Creating data center...', :magenta)}"

        datacenter_api = Ionoscloud::DataCenterApi.new(api_client)
        

        datacenter, _, headers  = datacenter_api.datacenters_post_with_http_info({
          'properties' => {
            'name' => config[:name],
            'description' => config[:description],
            'location' => config[:location]
          }
        }, default_opts)

        request_id = headers['Location'].scan(%r{/requests/(\b[0-9a-f]{8}\b-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-\b[0-9a-f]{12}\b)}).last.first

        dot = ui.color('.', :magenta)
        api_client.wait_for { print dot; is_done? request_id }

        @dcid = datacenter.id
        puts "\n"
        puts "#{ui.color('ID', :cyan)}: #{datacenter.id}"
        puts "#{ui.color('Name', :cyan)}: #{datacenter.properties.name}"
        puts "#{ui.color('Description', :cyan)}: #{datacenter.properties.description}"
        puts "#{ui.color('Location', :cyan)}: #{datacenter.properties.location}"
        puts 'done'
      end
    end
  end
end
