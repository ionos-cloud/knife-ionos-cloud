require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudDatacenterGet < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud datacenter get (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'ID of the data center'

      def initialize(args = [])
        super(args)
        @description =
        'Retrieves information about a Ionoscloud Datacenter.'
        @directory = 'compute-engine'
        @required_options = [:datacenter_id]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        print_datacenter(Ionoscloud::DataCentersApi.new(api_client).datacenters_find_by_id(config[:datacenter_id]))
      end
    end
  end
end
