require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudPccUpdate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud pcc update (options)'

      option :pcc_id,
              short: '-P PRIVATE_CROSS_CONNECT_ID',
              long: '--pcc-id PRIVATE_CROSS_CONNECT_ID',
              description: 'ID of the Private Cross Connect'

      option :name,
              short: '-n NAME',
              long: '--name NAME',
              description: 'Name of the data center'

      option :description,
              long: '--description DESCRIPTION',
              description: 'Description of the data center'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Updates information about a Ionoscloud Private Cross Connect. In order to add LANs to the Private Cross Connect one should'\
        'update the LAN and change the pcc property using the ```text\knife ionscloud lan update\n``` command.'
        @required_options = [:pcc_id, :ionoscloud_username, :ionoscloud_password]
        @updatable_fields = [:name, :description]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        pcc_api = Ionoscloud::PrivateCrossConnectsApi.new(api_client)

        if @updatable_fields.map { |el| config[el] }.any?
          print "#{ui.color('Updating Private Cross Connect...', :magenta)}"

          _, _, headers  = pcc_api.pccs_patch_with_http_info(
            config[:pcc_id],
            Ionoscloud::PrivateCrossConnectProperties.new(
              name: config[:name],
              description: config[:description],
            )
          )

          dot = ui.color('.', :magenta)
          api_client.wait_for { print dot; is_done? get_request_id headers }
        else
          ui.warn("Nothing to update, please set one of the attributes #{@updatable_fields}.")
        end

        print_pcc(pcc_api.pccs_find_by_id(config[:pcc_id]))
      end
    end
  end
end
