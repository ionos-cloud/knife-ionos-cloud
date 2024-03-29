require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudLanList < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud lan list (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'The ID of the data center'

      def initialize(args = [])
        super(args)
        @description =
        'Lists all available LANs under a data center.'
        @directory = 'compute-engine'
        @required_options = [:datacenter_id]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        $stdout.sync = true
        handle_extra_config
        lan_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Public', :bold),
          ui.color('PCC', :bold),
        ]
        lan_api = Ionoscloud::LANsApi.new(api_client)

        lan_api.datacenters_lans_get(config[:datacenter_id], { depth: 1 }).items.each do |lan|
          lan_list << lan.id
          lan_list << lan.properties.name
          lan_list << lan.properties.public.to_s
          lan_list << lan.properties.pcc
        end

        puts ui.list(lan_list, :uneven_columns_across, 4)
      end
    end
  end
end
