require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudSnapshotDelete < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud snapshot delete SNAPSHOT_ID [SNAPSHOT_ID]'

      attr_reader :description, :required_options
      
      def initialize(args = [])
        super(args)
        @description =
        'Deletes the specified snapshot.'
        @required_options = [:ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        validate_required_params(@required_options, config)

        snapshot_api = Ionoscloud::SnapshotApi.new(api_client)

        @name_args.each do |snapshot_id|
          begin
            snapshot = snapshot_api.snapshots_find_by_id(snapshot_id)
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("Snapshot ID #{snapshot_id} not found. Skipping.")
            next
          end

          msg_pair('ID', snapshot.id)
          msg_pair('Name', snapshot.properties.name)
          msg_pair('Description', snapshot.properties.description)
          msg_pair('Location', snapshot.properties.location)
          msg_pair('Size', snapshot.properties.size.to_s)

          puts "\n"

          begin
            confirm('Do you really want to delete this Snapshot')
          rescue SystemExit => exc
            next
          end

          _, _, headers = snapshot_api.snapshots_delete_with_http_info(snapshot_id)
          ui.warn("Deleted Snapshot #{snapshot.id}. Request ID: #{get_request_id headers}")
        end
      end
    end
  end
end
