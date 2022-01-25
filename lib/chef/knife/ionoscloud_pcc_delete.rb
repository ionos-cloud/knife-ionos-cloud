require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudPccDelete < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud pcc delete PCC_ID [PCC_ID]'

      def initialize(args = [])
        super(args)
        @description =
        'Deletes a Private Cross-Connect.'
        @directory = 'compute-engine'
        @required_options = [:ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        pcc_api = Ionoscloud::PrivateCrossConnectsApi.new(api_client)

        @name_args.each do |pcc_id|
          begin
            pcc = pcc_api.pccs_find_by_id(pcc_id)
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("PCC ID #{pcc_id} not found. Skipping.")
            next
          end

          print_pcc(pcc)
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
