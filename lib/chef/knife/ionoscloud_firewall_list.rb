require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudFirewallList < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud firewall list (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'ID of the data center'

      option :server_id,
              short: '-S SERVER_ID',
              long: '--server-id SERVER_ID',
              description: 'The ID of the server'

      option :nic_id,
              short: '-N NIC_ID',
              long: '--nic-id NIC_ID',
              description: 'ID of the NIC'

      def initialize(args = [])
        super(args)
        @description =
        'Lists all available firewall rules assigned to a NIC.'
        @directory = 'compute-engine'
        @required_options = [:datacenter_id, :server_id, :nic_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        firewall_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Protocol', :bold),
          ui.color('Source MAC', :bold),
          ui.color('Source IP', :bold),
          ui.color('Target IP', :bold),
          ui.color('Port Range Start', :bold),
          ui.color('Port Range End', :bold),
          ui.color('ICMP Type', :bold),
          ui.color('ICMP CODE', :bold),
          ui.color('Type', :bold),
        ]

        firewallrules_api = Ionoscloud::FirewallRulesApi.new(api_client)

        firewallrules_api.datacenters_servers_nics_firewallrules_get(
          config[:datacenter_id], config[:server_id], config[:nic_id], { depth: 1 }
        ).items.each do |firewall|
          firewall_list << firewall.id
          firewall_list << firewall.properties.name
          firewall_list << firewall.properties.protocol.to_s
          firewall_list << firewall.properties.source_mac.to_s
          firewall_list << firewall.properties.source_ip.to_s
          firewall_list << firewall.properties.target_ip.to_s
          firewall_list << firewall.properties.port_range_start.to_s
          firewall_list << firewall.properties.port_range_end.to_s
          firewall_list << firewall.properties.icmp_type.to_s
          firewall_list << firewall.properties.icmp_code.to_s
          firewall_list << firewall.properties.type.to_s
        end

        puts ui.list(firewall_list, :uneven_columns_across, 11)
      end
    end
  end
end
