require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudUserSsourl < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud user ssourl (options)'

      option :user_id,
              short: '-U USER_ID',
              long: '--user-id USER_ID',
              description: 'The ID of the Backup unit.'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Retrieve S3 object storage single signon URL for the given user.'
        @required_options = [:user_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        begin
          puts Ionoscloud::UserS3KeysApi.new(api_client).um_users_s3ssourl_get(config[:user_id]).sso_url
        rescue Ionoscloud::ApiError => err
          raise err unless err.code == 404
          ui.error("User ID #{config[:user_id]} not found.")
        end
      end
    end
  end
end
