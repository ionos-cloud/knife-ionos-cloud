require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudLanCreate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud lan create (options)'

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
              description: 'Boolean indicating if the LAN faces the public ' \
                          'Internet or not; defaults to false'

      option :pcc,
              long: '--pcc PCC_ID',
              description: 'ID of the PCC to connect the LAN to'

      def initialize(args = [])
        super(args)
        @description =
        'Creates a new LAN under a data center.'
        @directory = 'compute-engine'
        @required_options = [:datacenter_id]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        print "#{ui.color('Creating LAN...', :magenta)}"

        lan_api = Ionoscloud::LANsApi.new(api_client)

        lan, _, headers = lan_api.datacenters_lans_post_with_http_info(
          config[:datacenter_id],
          Ionoscloud::Lan.new(
            properties: Ionoscloud::LanProperties.new(
              name: config[:name],
              public: config[:public],
              pcc: config[:pcc],
            ),
          ),
        )

        dot = ui.color('.', :magenta)
        api_client.wait_for { print dot; is_done? get_request_id headers }

        print_lan(lan_api.datacenters_lans_find_by_id(config[:datacenter_id], lan.id))
      end
    end
  end
end
