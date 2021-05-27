require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudVolumeDetach < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud volume detach VOLUME_ID [VOLUME_ID] (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'The ID of the data center'

      option :server_id,
              short: '-S SERVER_ID',
              long: '--server-id SERVER_ID',
              description: 'The ID of the server'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        "This will detach the volume from the server. Depending on the volume "\
        "HotUnplug settings, this may result in the server being rebooted.\n\n"\
        "This will NOT delete the volume from your virtual data center. You will "\
        "need to make a separate request to delete a volume."
        @required_options = [:datacenter_id, :server_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        validate_required_params(@required_options, config)

        server_api = Ionoscloud::ServersApi.new(api_client)

        @name_args.each do |volume_id|
          begin
            volume = server_api.datacenters_servers_volumes_find_by_id(
              config[:datacenter_id],
              config[:server_id],
              volume_id,
            )
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("Volume ID #{volume_id} not found. Skipping.")
            next
          end

          msg_pair('ID', volume.id)
          msg_pair('Name', volume.properties.name)
          msg_pair('Size', volume.properties.size)
          msg_pair('Bus', volume.properties.bus)
          msg_pair('Image', volume.properties.image)
          msg_pair('Type', volume.properties.type)
          msg_pair('Licence Type', volume.properties.licence_type)
          msg_pair('Zone', volume.properties.availability_zone)

          begin
            confirm('Do you really want to detach this volume')
          rescue SystemExit => exc
            next
          end

          _, _, headers = server_api.datacenters_servers_volumes_delete_with_http_info(
            config[:datacenter_id],
            config[:server_id],
            volume.id,
          )

          ui.msg("Detaching Volume #{volume_id} from server. Request ID: #{get_request_id headers}")
        end
      end
    end
  end
end
