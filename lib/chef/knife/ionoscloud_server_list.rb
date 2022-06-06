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

      option :upgrade_needed,
              short: '-u',
              long: '--upgrade-needed',
              description: 'It can be used to filter which servers can be upgraded'

      def initialize(args = [])
        super(args)
        @description =
        'List all available servers under a specified data center.'
        @directory = 'compute-engine'
        @required_options = [:datacenter_id]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        server_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Type', :bold),
          ui.color('Template', :bold),
          ui.color('Cores', :bold),
          ui.color('CPU Family', :bold),
          ui.color('RAM', :bold),
          ui.color('VM State', :bold),
          ui.color('Boot Volume', :bold),
          ui.color('Boot CDROM', :bold),
        ]

        server_api = Ionoscloud::ServersApi.new(api_client)

        opts = { depth: 1 }

        opts[:upgrade_needed] = config[:upgrade_needed] if config[:upgrade_needed]

        server_api.datacenters_servers_get(config[:datacenter_id], opts).items.each do |server|
          server_list << server.id
          server_list << server.properties.name
          server_list << server.properties.type
          server_list << server.properties.template_uuid
          server_list << server.properties.cores.to_s
          server_list << server.properties.cpu_family
          server_list << server.properties.ram.to_s
          server_list << server.properties.vm_state
          server_list << (server.properties.boot_volume.nil? ? '' : server.properties.boot_volume.id)
          server_list << (server.properties.boot_cdrom.nil? ? '' : server.properties.boot_cdrom.id)
        end

        puts ui.list(server_list, :uneven_columns_across, 10)
      end
    end
  end
end
