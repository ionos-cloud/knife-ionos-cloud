require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudRequestStatus < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud request status (options)'

      option :request_id,
              short: '-R REQUEST_ID',
              long: '--request-id REQUEST_ID',
              description: 'The ID of the Request.'

      def initialize(args = [])
        super(args)
        @description =
        'Retrieves the status of a specific request based on the supplied request id.'
        @directory = 'compute-engine'
        @required_options = [:request_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        begin
          puts Ionoscloud::RequestsApi.new(api_client).requests_status_get(config[:request_id]).metadata.status
        rescue Ionoscloud::ApiError => err
          raise err unless err.code == 404
          ui.error("Request ID #{config[:request_id]} not found.")
        end
      end
    end
  end
end
