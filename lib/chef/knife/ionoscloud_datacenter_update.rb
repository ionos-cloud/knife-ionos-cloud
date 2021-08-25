require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudDatacenterUpdate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud datacenter update (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'ID of the data center'

      option :name,
              short: '-n NAME',
              long: '--name NAME',
              description: 'Name of the data center'

      option :description,
              short: '-d DESCRIPTION',
              long: '--description DESCRIPTION',
              description: 'Description of the data center'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Retries information about a Ionoscloud Datacenter.'
        @required_options = [:datacenter_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        datacenter_api = Ionoscloud::DataCenterApi.new(api_client)

        datacenter, _, headers  = datacenter_api.datacenters_patch_with_http_info(
          config[:datacenter_id],
          Ionoscloud::DatacenterProperties.new(
            name: config[:name],
            description: config[:description],
          )
        )

        print "#{ui.color('Updating data center...', :magenta)}"
        dot = ui.color('.', :magenta)
        api_client.wait_for { print dot; is_done? get_request_id headers }

        print_datacenter(datacenter_api.datacenters_find_by_id(datacenter.id))
      end
    end
  end
end
