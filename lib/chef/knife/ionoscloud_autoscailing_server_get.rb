require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudAutoscailingGrouServerpGet < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud vm autoscailing group server get (options)'

      option :group_id,
              short: '-G GROUP_ID',
              long: '--group-id GROUP_ID',
              description: 'ID of the vm autoscailing group'

      option :server_id,
              short: '-S SERVER_ID',
              long: '--server-id SERVER',
              description: 'ID of the vm autoscailing group server'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Retrieves information about a Ionoscloud vm Autoscailing Group Server.'
        @required_options = [:group_id, :server_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        print_autoscailing_group_server(
          IonoscloudAutoscaling::GroupsApi.new(api_client).autoscaling_groups_servers_find_by_id_with_http_info(
            config[:group_id], 
            config[:server_id],
          ),
        )
      end
    end
  end
end
