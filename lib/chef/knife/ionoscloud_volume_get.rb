require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudVolumeGet < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud volume get (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'ID of the data center'

      option :volume_id,
              long: '--volume VOLUME_ID',
              description: 'ID of the volume.'

      def initialize(args = [])
        super(args)
        @description =
        'Retrieves the attributes of a given Volume.'
        @directory = 'compute-engine'
        @required_options = [:datacenter_id, :volume_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)
        print_volume(Ionoscloud::VolumesApi.new(api_client).datacenters_volumes_find_by_id(config[:datacenter_id], config[:volume_id]))
      end
    end
  end
end
