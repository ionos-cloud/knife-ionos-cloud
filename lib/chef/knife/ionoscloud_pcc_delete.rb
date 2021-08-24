require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudPccDelete < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud pcc delete PCC_ID [PCC_ID]'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Deletes a Private Cross-Connect.'
        @required_options = [:ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        validate_required_params

        pcc_api = Ionoscloud::PrivateCrossConnectsApi.new(api_client)

        @name_args.each do |pcc_id|
          begin
            pcc = pcc_api.pccs_find_by_id(pcc_id)
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("PCC ID #{pcc_id} not found. Skipping.")
            next
          end

          peers = pcc.properties.peers.map { |peer| peer.id }
          datacenters = pcc.properties.connectable_datacenters.map { |datacenter| datacenter.id }

          msg_pair('ID', pcc.id)
          msg_pair('Name', pcc.properties.name)
          msg_pair('Description', pcc.properties.description)
          msg_pair('Peers', peers.to_s)
          msg_pair('Datacenters', datacenters.to_s)

          puts "\n"

          begin
            confirm('Do you really want to delete this PCC')
          rescue SystemExit => exc
            next
          end

          _, _, headers = pcc_api.pccs_delete_with_http_info(pcc_id)
          ui.warn("Deleted PCC #{pcc.id}. Request ID: #{get_request_id headers}")
        end
      end
    end
  end
end
