require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudSnapshotCreate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud snapshot create (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter DATACENTER_ID',
              description: 'ID of the Datacenter'

      option :volume_id,
              short: '-V VOLUME_ID',
              long: '--volume VOLUME_ID',
              description: 'ID of the Volume'

      option :name,
              short: '-n SNAPSHOT_NAME',
              long: '--name SNAPSHOT_NAME',
              description: 'Name of the snapshot'

      option :description,
              long: '--description SNAPSHOT_DESCRIPTION',
              description: 'Description of the snapshot'

      option :sec_auth_protection,
              long: '--sec-auth',
              description: 'Flag representing if extra protection is enabled on snapshot e.g. Two Factor protection etc.'

      option :licence_type,
              short: '-l LICENCE_TYPE',
              long: '--licence LICENCE_TYPE',
              description: 'The OS type of this Snapshot'

      def initialize(args = [])
        super(args)
        @description =
        'Creates a snapshot of a volume within the virtual data center. '\
        'You can use a snapshot to create a new storage volume or to restore a storage volume.'
        @directory = 'compute-engine'
        @required_options = [:datacenter_id, :volume_id]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        print "#{ui.color('Creating Snapshot...', :magenta)}"

        volume_api = Ionoscloud::VolumesApi.new(api_client)

        snapshot, _, headers  = volume_api.datacenters_volumes_create_snapshot_post_with_http_info(
          config[:datacenter_id],
          config[:volume_id],
          {
            name: config[:name],
            description: config[:description],
            sec_auth_protection: config[:sec_auth_protection],
            licence_type: config[:licence_type],
          }.compact,
        )

        dot = ui.color('.', :magenta)
        api_client.wait_for { print dot; is_done? get_request_id headers }

        print_snapshot(Ionoscloud::SnapshotsApi.new(api_client).snapshots_find_by_id(snapshot.id))
      end
    end
  end
end
