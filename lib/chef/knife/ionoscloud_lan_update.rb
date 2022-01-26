require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudLanUpdate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud lan update (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'ID of the data center'

      option :lan_id,
              short: '-L LAN_ID',
              long: '--lan-id LAN_ID',
              description: 'ID of the LAN'

      option :name,
              short: '-n NAME',
              long: '--name NAME',
              description: 'Name of the server'

      option :public,
              short: '-p PUBLIC',
              long: '--public PUBLIC',
              boolean: true,
              description: 'Boolean indicating if the LAN faces the public ' \
                          'Internet or not; defaults to false'

      option :pcc,
              long: '--pcc PCC_ID',
              description: 'ID of the PCC to connect the LAN to'

      def initialize(args = [])
        super(args)
        @description =
        'Updates information about a Ionoscloud LAN.'
        @directory = 'compute-engine'
        @required_options = [:datacenter_id, :lan_id, :ionoscloud_username, :ionoscloud_password]
        @updatable_fields = [:name, :public, :pcc, :description]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        lan_api = Ionoscloud::LANsApi.new(api_client)

        if @updatable_fields.map { |el| config[el] }.any?
          print "#{ui.color('Updating LAN...', :magenta)}"

          _, _, headers  = lan_api.datacenters_lans_patch_with_http_info(
            config[:datacenter_id],
            config[:lan_id],
            Ionoscloud::LanProperties.new(
              name: config[:name],
              public: (config.key?(:public) ? config[:public].to_s.downcase == 'true' : nil),
              pcc: config[:pcc],
            ),
          )

          dot = ui.color('.', :magenta)
          api_client.wait_for { print dot; is_done? get_request_id headers }
        else
          ui.warn("Nothing to update, please set one of the attributes #{@updatable_fields}.")
        end

        print_lan(lan_api.datacenters_lans_find_by_id(config[:datacenter_id], config[:lan_id]))
      end
    end
  end
end
