require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudS3keyList < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud s3key list (options)'

      option :user_id,
              short: '-u USER_ID',
              long: '--user USER_ID',
              description: 'The ID of the user'

      def initialize(args = [])
        super(args)
        @description =
        'Retrieve a list of all the S3 keys for a specific user.'
        @directory = 'user'
        @required_options = [:user_id]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        s3key_list = [
          ui.color('ID', :bold),
          ui.color('Secret Key', :bold),
          ui.color('Active', :bold),
        ]

        user_s3keys_api = Ionoscloud::UserS3KeysApi.new(api_client)

        user_s3keys_api.um_users_s3keys_get(config[:user_id], { depth: 1 }).items.each do |s3_key|
          s3key_list << s3_key.id
          s3key_list << s3_key.properties.secret_key
          s3key_list << s3_key.properties.active.to_s
        end

        puts ui.list(s3key_list, :uneven_columns_across, 3)
      end
    end
  end
end
