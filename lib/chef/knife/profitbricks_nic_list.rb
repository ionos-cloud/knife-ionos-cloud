require 'chef/knife/profitbricks_base'

class Chef
  class Knife
    class ProfitbricksNicList < Knife
      include Knife::ProfitbricksBase

      banner 'knife profitbricks nic list (options)'

      option :datacenter_id,
             short: '-D DATACENTER_ID',
             long: '--datacenter-id DATACENTER_ID',
             description: 'The ID of the datacenter containing the NIC'

      option :server_id,
             short: '-S SERVER_ID',
             long: '--server-id SERVER_ID',
             description: 'The ID of the server assigned the NIC'

      def run
        $stdout.sync = true
        validate_required_params(%i(datacenter_id server_id), config)

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
