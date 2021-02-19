require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudDatacenterCreate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud datacenter create (options)'

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
      
      attr_reader :description, :required_options
      
      def initialize(args = [])
        super(args)
        @description =
        "Unless you are planning to manage an existing Ionoscloud environment, "\
        "the first step will typically involve choosing the location for a new virtual data center"\
        "A list of locations can be obtained with location command.\n\n\t"\
        "knife ionoscloud location list\n\n"\
        "Make a note of the desired location ID and now the data center can be created.\n"
        @required_options = [:location, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        validate_required_params(@required_options, config)

        print "#{ui.color('Creating data center...', :magenta)}"

        datacenter_api = Ionoscloud::DataCenterApi.new(api_client)

        datacenter, _, headers  = datacenter_api.datacenters_post_with_http_info({
          properties: {
            name: config[:name],
            description: config[:description],
            location: config[:location],
          }.compact,
        })

        dot = ui.color('.', :magenta)
        api_client.wait_for { print dot; is_done? get_request_id headers }

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
