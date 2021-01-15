require 'chef/knife/profitbricks_base'

class Chef
  class Knife
    class ProfitbricksDatacenterCreate < Knife
      include Knife::ProfitbricksBase

      banner 'knife profitbricks datacenter create (options)'

      option :name,
             short: '-n NAME',
             long: '--name NAME',
             description: 'Name of the data center',
             proc: proc { |name| Chef::Config[:knife][:name] = name }

      option :description,
             short: '-D DESCRIPTION',
             long: '--description DESCRIPTION',
             description: 'Description of the data center',
             proc: proc { |description| Chef::Config[:knife][:description] = description }

      option :location,
             short: '-l LOCATION',
             long: '--location LOCATION',
             description: 'Location of the data center',
             proc: proc { |location| Chef::Config[:knife][:location] = location }

      def run
        $stdout.sync = true

        validate_required_params(%i(name location), Chef::Config[:knife])

        print "#{ui.color('Creating data center...', :magenta)}"

        data_center_api = Ionoscloud::DataCenterApi.new(api_client)
        

        datacenter, _, headers  = data_center_api.datacenters_post_with_http_info({
          'properties' => {
            'name' => Chef::Config[:knife][:name],
            'description' => Chef::Config[:knife][:description],
            'location' => Chef::Config[:knife][:location]
          }
        }, default_opts)

        request_id = headers['Location'].scan(%r{/requests/(\b[0-9a-f]{8}\b-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-\b[0-9a-f]{12}\b)}).last.first
        # puts "\n"
        # puts request_id

        # dot = ui.color('.', :magenta)
        api_client.wait_for_completion(request_id)
        # print dot; ready?

        # datacenter.wait_for { print dot; ready? }

        # print dot

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
