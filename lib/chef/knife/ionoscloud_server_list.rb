require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudServerList < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud server list (options)'

      option :datacenter_id,
             short: '-D DATACENTER_ID',
             long: '--datacenter-id DATACENTER_ID',
             description: 'The ID of the datacenter containing the server'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'List all available servers under a specified data center.'
        @required_options = [:datacenter_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        validate_required_params(@required_options, config)

        server_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Cores', :bold),
          ui.color('RAM', :bold),
          ui.color('Availability Zone', :bold),
          ui.color('VM State', :bold),
          ui.color('Boot Volume', :bold),
          ui.color('Boot CDROM', :bold)
        ]

        server_api = Ionoscloud::ServerApi.new(api_client)

        server_api.datacenters_servers_get(config[:datacenter_id], { depth: 1 }).items.each do |server|
          server_list << server.id
          server_list << server.properties.name
          server_list << server.properties.cores.to_s
          server_list << server.properties.ram.to_s
          server_list << server.properties.availability_zone
          server_list << server.properties.vm_state
          server_list << server.properties.boot_volume || ''
          server_list << server.properties.boot_cdrom || ''
        end

        puts ui.list(server_list, :uneven_columns_across, 8)
      end
    end
  end
end
