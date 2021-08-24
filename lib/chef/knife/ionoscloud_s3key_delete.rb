require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudS3keyDelete < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud s3key delete S3KEY_ID [S3KEY_ID] (options)'

      option :user_id,
              short: '-u USER_ID',
              long: '--user USER_ID',
              description: 'The ID of the user'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'This operation deletes a specific S3 key.'
        @required_options = [:user_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        validate_required_params

        user_s3keys_api = Ionoscloud::UserS3KeysApi.new(api_client)

        @name_args.each do |s3key_id|
          begin
            s3_key = user_s3keys_api.um_users_s3keys_find_by_key_id(config[:user_id], s3key_id)
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("S3 key ID #{s3key_id} not found. Skipping.")
            next
          end

          msg_pair('ID', s3_key.id)
          msg_pair('Secret Key', s3_key.properties.secret_key)
          msg_pair('Active', s3_key.properties.active.to_s)

          puts "\n"

          begin
            confirm('Do you really want to delete this S3 key')
          rescue SystemExit => exc
            next
          end

          _, _, headers = user_s3keys_api.um_users_s3keys_delete_with_http_info(config[:user_id], s3key_id)
          ui.warn("Deleted S3 key #{s3_key.id}. Request ID: #{get_request_id headers}")
        end
      end
    end
  end
end
