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

        print_datacenter(Ionoscloud::DataCenterApi.new(api_client).datacenters_find_by_id(config[:datacenter_id]))
      end
    end
  end
end
