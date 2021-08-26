require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudNicList < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud nic list (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'The ID of the datacenter containing the NIC'

      option :server_id,
              short: '-S SERVER_ID',
              long: '--server-id SERVER_ID',
              description: 'The ID of the server assigned the NIC'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'List all available NICs connected to a server.'
        @required_options = [:datacenter_id, :server_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        nic_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('IPs', :bold),
          ui.color('DHCP', :bold),
          ui.color('NAT', :bold),
          ui.color('LAN', :bold)
        ]

        nic_api = Ionoscloud::NicApi.new(api_client)

        nic_api.datacenters_servers_nics_get(config[:datacenter_id], config[:server_id], { depth: 1 }).items.each do |nic|
          nic_list << nic.id
          nic_list << nic.properties.name
          nic_list << nic.properties.ips.to_s
          nic_list << nic.properties.dhcp.to_s
          nic_list << nic.properties.nat.to_s
          nic_list << nic.properties.lan.to_s
        end

        puts ui.list(nic_list, :uneven_columns_across, 6)
      end
    end
  end
end
