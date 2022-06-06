require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudS3keyCreate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud s3key create (options)'

      option :user_id,
              short: '-u USER_ID',
              long: '--user USER_ID',
              description: 'The ID of the user'

      def initialize(args = [])
        super(args)
        @description =
        'Creates a new S3 key for a particular user.'
        @directory = 'user'
        @required_options = [:user_id]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        print "#{ui.color('Creating S3key...', :magenta)}"

        user_s3keys_api = Ionoscloud::UserS3KeysApi.new(api_client)

        s3_key, _, headers  = user_s3keys_api.um_users_s3keys_post_with_http_info(config[:user_id])

        dot = ui.color('.', :magenta)
        api_client.wait_for { print dot; is_done? get_request_id headers }

        print_s3key(s3_key)
      end
    end
  end
end
