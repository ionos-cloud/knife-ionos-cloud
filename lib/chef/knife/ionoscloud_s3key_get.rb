require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudS3keyGet < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud s3key get (options)'

      option :user_id,
              short: '-u USER_ID',
              long: '--user USER_ID',
              description: 'The ID of the user'

      option :s3_key_id,
              short: '-S S3KEY_ID',
              long: '--s3-key S3KEY_ID',
              description: 'The ID of the S3 Key.'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Retrieves the properties of an S3 Key.'
        @required_options = [:user_id, :s3_key_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        print_s3key(Ionoscloud::UserS3KeysApi.new(api_client).um_users_s3keys_find_by_key_id(config[:user_id], config[:s3_key_id]))
      end
    end
  end
end
