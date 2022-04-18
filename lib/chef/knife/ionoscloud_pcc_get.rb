require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudPccGet < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud pcc get (options)'

      option :pcc_id,
              short: '-P PRIVATE_CROSS_CONNECT_ID',
              long: '--pcc-id PRIVATE_CROSS_CONNECT_ID',
              description: 'ID of the Private Cross Connect'

      def initialize(args = [])
        super(args)
        @description =
        'Retrieves information about a Ionoscloud Private Cross Connect.'
        @directory = 'compute-engine'
        @required_options = [:pcc_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        print_pcc(Ionoscloud::PrivateCrossConnectsApi.new(api_client).pccs_find_by_id(config[:pcc_id]))
      end
    end
  end
end
