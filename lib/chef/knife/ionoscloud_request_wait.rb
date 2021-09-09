require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudRequestWait < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud request wait (options)'

      option :request_id,
              short: '-R REQUEST_ID',
              long: '--request-id REQUEST_ID',
              description: 'The ID of the Backup unit.'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Waits until a request status is either DONE or FAILED.'
        @required_options = [:request_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        print "#{ui.color('Waiting for request...', :magenta)}"

        begin
          dot = ui.color('.', :magenta)
          api_client.wait_for { print dot; is_done? config[:request_id] }
        rescue Ionoscloud::ApiError => err
          raise err unless err.code == 404
          ui.error("Request ID #{config[:request_id]} not found.")
        end
        print "\n"
      end
    end
  end
end
