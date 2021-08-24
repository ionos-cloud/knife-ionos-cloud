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

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Retrieves the status of a specific request based on the supplied request id.'
        @required_options = [:request_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        validate_required_params

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
