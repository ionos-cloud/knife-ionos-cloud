require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudLanDelete < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud lan delete LAN_ID [LAN_ID] (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'Name of the data center'

      def initialize(args = [])
        super(args)
        @description =
        'Deletes an existing LAN.'
        @directory = 'compute-engine'
        @required_options = [:datacenter_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        lan_api = Ionoscloud::LANsApi.new(api_client)
        @name_args.each do |lan_id|
          begin
            lan = lan_api.datacenters_lans_find_by_id(config[:datacenter_id], lan_id)
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("Lan ID #{lan_id} not found. Skipping.")
            next
          end

          print_lan(lan)
          puts "\n"

          begin
            confirm('Do you really want to delete this LAN')
          rescue SystemExit
            next
          end

          _, _, headers = lan_api.datacenters_lans_delete_with_http_info(config[:datacenter_id], lan.id)
          ui.warn("Deleted Lan #{lan.id}. Request ID: #{get_request_id headers}")
        end
      end
    end
  end
end
