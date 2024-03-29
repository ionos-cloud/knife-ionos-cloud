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

      def initialize(args = [])
        super(args)
        @description =
        'Unless you are planning to manage an existing Ionoscloud environment, '\
        'the first step will typically involve choosing the location for a new virtual data center'\
        "A list of locations can be obtained with location command.\n\n\t"\
        "```text\nknife ionoscloud location list\n```\n\n"\
        "Make a note of the desired location ID and now the data center can be created.\n"
        @directory = 'compute-engine'
        @required_options = [:location]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        print "#{ui.color('Creating data center...', :magenta)}"

        datacenter_api = Ionoscloud::DataCentersApi.new(api_client)

        datacenter, _, headers  = datacenter_api.datacenters_post_with_http_info(
          Ionoscloud::Datacenter.new(
            properties: Ionoscloud::DatacenterProperties.new(
              name: config[:name],
              description: config[:description],
              location: config[:location],
            ),
          ),
        )

        dot = ui.color('.', :magenta)
        api_client.wait_for { print dot; is_done? get_request_id headers }

        print_datacenter(datacenter)
      end
    end
  end
end
