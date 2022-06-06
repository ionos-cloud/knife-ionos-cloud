require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudSnapshotGet < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud snapshot get (options)'

      option :snapshot_id,
              short: '-S SNAPSHOT_ID',
              long: '--snapshot-id SNAPSHOT_ID',
              description: 'ID of the group.'

      def initialize(args = [])
        super(args)
        @description =
        'Retrieves the attributes of a given Snapshot.'
        @directory = 'compute-engine'
        @required_options = [:snapshot_id]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)
        print_snapshot(Ionoscloud::SnapshotsApi.new(api_client).snapshots_find_by_id(config[:snapshot_id]))
      end
    end
  end
end
