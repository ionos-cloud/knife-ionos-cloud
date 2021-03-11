require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudSnapshotRestore < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud snapshot restore (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter DATACENTER_ID',
              description: 'ID of the Datacenter'

      option :volume_id,
              short: '-V VOLUME_ID',
              long: '--volume VOLUME_ID',
              description: 'ID of the Volume'

      option :snapshot_id,
              short: '-S SNAPSHOT_ID',
              long: '--snapshot SNAPSHOT_ID',
              description: 'ID of the Snapshot'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'This will restore a snapshot onto a volume. A snapshot is created as just another image that '\
        'can be used to create new volumes or to restore an existing volume.'
        @required_options = [:datacenter_id, :volume_id, :snapshot_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        validate_required_params(@required_options, config)

        print "#{ui.color('Restoring Snapshot...', :magenta)}"

        volume_api = Ionoscloud::VolumeApi.new(api_client)

        _, _, headers  = volume_api.datacenters_volumes_restore_snapshot_post_with_http_info(
          config[:datacenter_id],
          config[:volume_id],
          { snapshot_id: config[:snapshot_id] },
        )

        dot = ui.color('.', :magenta)
        api_client.wait_for { print dot; is_done? get_request_id headers }

        volume_api = Ionoscloud::VolumeApi.new(api_client)

        volume = volume_api.datacenters_volumes_find_by_id(config[:datacenter_id], config[:volume_id])

        puts "\n"
        puts "#{ui.color('ID', :cyan)}: #{volume.id}"
        puts "#{ui.color('Name', :cyan)}: #{volume.properties.name}"
        puts "#{ui.color('Size', :cyan)}: #{volume.properties.size}"
        puts "#{ui.color('Bus', :cyan)}: #{volume.properties.bus}"
        puts "#{ui.color('Image', :cyan)}: #{volume.properties.image}"
        puts "#{ui.color('Type', :cyan)}: #{volume.properties.type}"
        puts "#{ui.color('Licence Type', :cyan)}: #{volume.properties.licence_type}"
        puts "#{ui.color('Zone', :cyan)}: #{volume.properties.availability_zone}"
        puts 'done'
      end
    end
  end
end
