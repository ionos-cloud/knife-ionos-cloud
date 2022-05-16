require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudVolumeDelete < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud volume delete SERVER_ID [SERVER_ID] (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'Name of the data center'

      def initialize(args = [])
        super(args)
        @description =
        'Deletes the specified volume. This will result in the volume being '\
        'removed from your virtual data center. Please use this with caution!'
        @directory = 'compute-engine'
        @required_options = [:datacenter_id]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        volume_api = Ionoscloud::VolumesApi.new(api_client)

        @name_args.each do |volume_id|
          begin
            volume = volume_api.datacenters_volumes_find_by_id(
              config[:datacenter_id],
              volume_id,
            )
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("Volume ID #{volume_id} not found. Skipping.")
            next
          end

          print_volume(volume)
          puts "\n"

          begin
            confirm('Do you really want to delete this volume')
          rescue SystemExit
            next
          end

          _, _, headers = volume_api.datacenters_volumes_delete_with_http_info(
            config[:datacenter_id],
            volume_id,
          )
          ui.warn("Deleted Volume #{volume.id}. Request ID: #{get_request_id headers}")
        end
      end
    end
  end
end
