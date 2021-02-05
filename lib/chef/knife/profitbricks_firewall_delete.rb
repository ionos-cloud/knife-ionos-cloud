require 'chef/knife/ionoscloud_base'

class Chef
  class Knife
    class ProfitbricksFirewallDelete < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud firewall delete FIREWALL_ID [FIREWALL_ID] (options)'

      option :datacenter_id,
             short: '-D DATACENTER_ID',
             long: '--datacenter-id DATACENTER_ID',
             description: 'The ID of the data center'

      option :server_id,
             short: '-S SERVER_ID',
             long: '--server-id SERVER_ID',
             description: 'The ID of the server'
      option :nic_id,
             short: '-N NIC_ID',
             long: '--nic-id NIC_ID',
             description: 'ID of the NIC'

      def run
        validate_required_params(%i(datacenter_id server_id nic_id), config)
        
        nic_api = Ionoscloud::NicApi.new(api_client)

        @name_args.each do |firewall_id|
          begin
            firewall = nic_api.datacenters_servers_nics_firewallrules_find_by_id(
              config[:datacenter_id], config[:server_id], config[:nic_id], firewall_id,
            )
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("Firewall rule ID #{firewall_id} not found. Skipping.")
            next
          end

          msg_pair('ID', firewall.id)
          msg_pair('Name', firewall.properties.name)
          msg_pair('Protocol', firewall.properties.protocol)
          msg_pair('Source MAC', firewall.properties.source_mac)
          msg_pair('Source IP', firewall.properties.source_ip)
          msg_pair('Target IP', firewall.properties.target_ip)
          msg_pair('Port Range Start', firewall.properties.port_range_start)
          msg_pair('Port Range End', firewall.properties.port_range_end)
          msg_pair('ICMP Type', firewall.properties.icmp_type)
          msg_pair('ICMP Code', firewall.properties.icmp_code)

          begin
            confirm('Do you really want to delete this firewall rule')
          rescue SystemExit => exc
            next
          end

          _, _, headers = nic_api.datacenters_servers_nics_firewallrules_delete_with_http_info(
            config[:datacenter_id], config[:server_id], config[:nic_id], firewall_id,
          )
          ui.warn("Deleted Firewall rule #{firewall.id}. Request ID: #{get_request_id headers}")
        end
      end
    end
  end
end
