require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudLanDelete < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud lan delete LAN_ID [LAN_ID] (options)'

      option :datacenter_id,
             short: '-D DATACENTER_ID',
             long: '--datacenter-id DATACENTER_ID',
             description: 'Name of the data center',
             proc: proc { |datacenter_id| Chef::Config[:knife][:datacenter_id] = datacenter_id }

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Deletes an existing LAN.'
        @required_options = [:datacenter_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        validate_required_params(@required_options, config)

        lan_api = Ionoscloud::LanApi.new(api_client)
        @name_args.each do |lan_id|
          begin
            lan = lan_api.datacenters_lans_find_by_id(config[:datacenter_id], lan_id)
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("Lan ID #{lan_id} not found. Skipping.")
            next
          end

          msg_pair('ID', lan.id)
          msg_pair('Name', lan.properties.name)
          msg_pair('Public', lan.properties.public.to_s)

          begin
            confirm('Do you really want to delete this LAN')
          rescue SystemExit => exc
            next
          end

          _, _, headers = lan_api.datacenters_lans_delete_with_http_info(config[:datacenter_id], lan.id)
          ui.warn("Deleted Lan #{lan.id}. Request ID: #{get_request_id headers}")
        end
      end
    end
  end
end
