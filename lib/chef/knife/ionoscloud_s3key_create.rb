require 'chef/knife/ionoscloud_base'

class Chef
  class Knife
    class IonoscloudS3keyCreate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud s3key create (options)'

      option :user,
              short: '-u USER_ID',
              long: '--user USER_ID',
              description: 'The ID of the user'

      def run
        $stdout.sync = true

        validate_required_params(%i(user), config)

        print "#{ui.color('Creating S3key...', :magenta)}"

        user_management_api = Ionoscloud::UserManagementApi.new(api_client)

        s3_key, _, headers  = user_management_api.um_users_s3keys_post_with_http_info(config[:user])

        dot = ui.color('.', :magenta)
        api_client.wait_for { print dot; is_done? get_request_id headers }

        puts "\n"
        puts "#{ui.color('ID', :cyan)}: #{s3_key.id}"
        puts "#{ui.color('Secret Key', :cyan)}: #{s3_key.properties.secret_key}"
        puts "#{ui.color('Etag', :cyan)}: #{s3_key.metadata.etag}"
        puts "#{ui.color('Active', :cyan)}: #{s3_key.properties.active}"
        puts 'done'
      end
    end
  end
end
