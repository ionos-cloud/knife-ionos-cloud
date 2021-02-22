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
              short: '-n NAME',
              long: '--name NAME',
              description: 'Name of the data center'

      option :description,
              short: '-d DESCRIPTION',
              long: '--description DESCRIPTION',
              description: 'Description of the data center'

      option :licence_type,
              short: '-l LICENCE_TYPE',
              long: '--licence-type LICENCE_TYPE',
              description: 'Set to one of the values: [WINDOWS, WINDOWS2016, LINUX, OTHER, UNKNOWN]'
      
      attr_reader :description, :required_options
      
      def initialize(args = [])
        super(args)
        @description =
        'Creates a snapshot of a volume within the virtual data center. '\
        'You can use a snapshot to create a new storage volume or to restore a storage volume.'
        @required_options = [:datacenter_id, :volume_id, :name, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        validate_required_params(@required_options, config)

        print "#{ui.color('Creating Snapshot...', :magenta)}"

        volume_api = Ionoscloud::VolumeApi.new(api_client)

        snapshot, _, headers  = volume_api.datacenters_volumes_create_snapshot_post_with_http_info(
          config[:datacenter_id],
          config[:volume_id],
          {
            properties: {
              name: config[:name],
              description: config[:description],
              licenceType: config[:licence_type],
          }.compact,
        })

        dot = ui.color('.', :magenta)
        api_client.wait_for { print dot; is_done? get_request_id headers }

        snapshot_api = Ionoscloud::SnapshotApi.new(api_client)

        snapshot = snapshot_api.snapshots_find_by_id(snapshot.id)

        puts "\n"
        puts "#{ui.color('ID', :cyan)}: #{snapshot.id}"
        puts "#{ui.color('Name', :cyan)}: #{snapshot.properties.name}"
        puts "#{ui.color('Description', :cyan)}: #{snapshot.properties.description}"
        puts "#{ui.color('Location', :cyan)}: #{snapshot.properties.location}"
        puts "#{ui.color('Size', :cyan)}: #{snapshot.properties.size.to_s}"
        puts 'done'
      end
    end
  end
end
