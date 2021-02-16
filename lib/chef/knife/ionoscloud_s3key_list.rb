require 'chef/knife/ionoscloud_base'

class Chef
  class Knife
    class IonoscloudS3keyList < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud s3key list (options)'

      option :user,
              short: '-u USER_ID',
              long: '--user USER_ID',
              description: 'The ID of the user'

      def run
        $stdout.sync = true

        validate_required_params(%i(user), config)

        s3key_list = [
          ui.color('ID', :bold),
          ui.color('Secret Key', :bold),
          ui.color('Etag', :bold),
          ui.color('Active', :bold),
        ]

        user_management_api = Ionoscloud::UserManagementApi.new(api_client)

        user_management_api.um_users_s3keys_get(config[:user], {depth: 1}).items.each do |s3_key|
          s3key_list << s3_key.id
          s3key_list << s3_key.properties.secret_key
          s3key_list << s3_key.metadata.etag
          s3key_list << s3_key.properties.active.to_s
        end

        puts ui.list(s3key_list, :uneven_columns_across, 4)
      end
    end
  end
end
