require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudSnapshotList < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud snapshot list'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Retrieve a list of snapshots.'
        @required_options = [:ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        snapshot_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Description', :bold),
          ui.color('Location', :bold),
          ui.color('Size', :bold)
        ]

        snapshot_api = Ionoscloud::SnapshotApi.new(api_client)

        snapshot_api.snapshots_get({ depth: 1 }).items.each do |snapshot|
          snapshot_list << snapshot.id
          snapshot_list << snapshot.properties.name
          snapshot_list << snapshot.properties.description || ''
          snapshot_list << snapshot.properties.location
          snapshot_list << snapshot.properties.size.to_s
        end

        puts ui.list(snapshot_list, :uneven_columns_across, 5)
      end
    end
  end
end
