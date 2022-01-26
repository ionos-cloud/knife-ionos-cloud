require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudPccList < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud pcc list'

      def initialize(args = [])
        super(args)
        @description =
        'Lists all Private Cross-Connect instances.'
        @directory = 'compute-engine'
        @required_options = [:ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        pcc_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Description', :bold),
        ]

        pcc_api = Ionoscloud::PrivateCrossConnectsApi.new(api_client)

        pcc_api.pccs_get({ depth: 1 }).items.each do |pcc|
          pcc_list << pcc.id
          pcc_list << pcc.properties.name
          pcc_list << pcc.properties.description || ''
        end

        puts ui.list(pcc_list, :uneven_columns_across, 3)
      end
    end
  end
end
