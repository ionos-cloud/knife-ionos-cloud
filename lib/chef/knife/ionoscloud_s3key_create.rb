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

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Creates a new S3 key for a particular user.'
        @required_options = [:user_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        print "#{ui.color('Creating S3key...', :magenta)}"

        user_management_api = Ionoscloud::UserManagementApi.new(api_client)

        s3_key, _, headers  = user_management_api.um_users_s3keys_post_with_http_info(config[:user_id])

        dot = ui.color('.', :magenta)
        api_client.wait_for { print dot; is_done? get_request_id headers }

        puts "\n"
        puts "#{ui.color('ID', :cyan)}: #{s3_key.id}"
        puts "#{ui.color('Secret Key', :cyan)}: #{s3_key.properties.secret_key}"
        puts "#{ui.color('Active', :cyan)}: #{s3_key.properties.active}"
        puts 'done'
      end
    end
  end
end
