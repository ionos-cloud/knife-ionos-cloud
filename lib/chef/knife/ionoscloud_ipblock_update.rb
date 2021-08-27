require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudIpblockUpdate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud ipblock update (options)'

      option :ipblock_id,
              short: '-I IPBLOCK_ID',
              long: '--ipblock-id IPBLOCK_ID',
              description: 'ID of the IPBlock.'

      option :name,
              short: '-n NAME',
              long: '--name NAME',
              description: 'Name of the IP block'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Updates information about an IP Block.'
        @required_options = [:ipblock_id, :ionoscloud_username, :ionoscloud_password]
        @updatable_fields = [:name]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        ipblock_api = Ionoscloud::IPBlocksApi.new(api_client)

        if @updatable_fields.map { |el| config[el] }.any?
          print "#{ui.color('Updating IP block...', :magenta)}"

          datacenter, _, headers  = ipblock_api.ipblocks_patch_with_http_info(
            config[:ipblock_id],
            Ionoscloud::IpBlockProperties.new(
              name: config[:name],
            ),
          )

          dot = ui.color('.', :magenta)
          api_client.wait_for { print dot; is_done? get_request_id headers }
        else
          ui.warn("Nothing to update, please set one of the attributes #{@updatable_fields}.")
        end

        print_ipblock(ipblock_api.ipblocks_find_by_id(config[:ipblock_id]))
      end
    end
  end
end
