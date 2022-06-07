require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudTargetgroupTargetRemove < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud targetgroup target remove (options)'

      option :target_group_id,
              short: '-T TARGET_GROUP_ID',
              long: '--target-group-id TARGET_GROUP_ID',
              description: 'ID of the Target Group'

      option :ip,
              long: '--ip IP',
              description: 'IP of a balanced target VM'

      option :port,
              short: '-p PORT',
              long: '--port PORT',
              description: 'Port of the balanced target service. (range: 1 to 65535)'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Removes a Target from a Target Group if it exists.'
        @directory = 'application-loadbalancer'
        @required_options = [:target_group_id, :ip, :port]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        target_groups_api = Ionoscloud::TargetGroupsApi.new(api_client)

        target_group = target_groups_api.targetgroups_find_by_target_group_id(config[:target_group_id])

        existing_target = target_group.properties.targets.find do |target|
          target.ip == config[:ip] && target.port == Integer(config[:port])
        end

        if existing_target
          target_group.properties.targets = target_group.properties.targets.reject do |target|
            target.ip == config[:ip] && target.port == Integer(config[:port])
          end

          _, _, headers = target_groups_api.targetgroups_patch_with_http_info(config[:target_group_id], target_group.properties)
          print "#{ui.color('Removing the Target from the Target Group...', :magenta)}"
          dot = ui.color('.', :magenta)
          api_client.wait_for { print dot; is_done? get_request_id headers }

          target_group = target_groups_api.targetgroups_find_by_target_group_id(config[:target_group_id])
        else
          ui.warn("Specified target does not exist (#{config[:ip]}:#{config[:port]}).")
        end

        print_target_group(target_group)
      end
    end
  end
end
