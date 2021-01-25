require 'chef/knife/profitbricks_base'

class Chef
  class Knife
    class ProfitbricksNicDelete < Knife
      include Knife::ProfitbricksBase

      banner 'knife profitbricks nic delete NIC_ID [NIC_ID] (options)'

      option :datacenter_id,
             short: '-D DATACENTER_ID',
             long: '--datacenter-id DATACENTER_ID',
             description: 'The ID of the data center',
             proc: proc { |datacenter_id| Chef::Config[:knife][:datacenter_id] = datacenter_id }

      option :server_id,
             short: '-S SERVER_ID',
             long: '--server-id SERVER_ID',
             description: 'The ID of the server assigned the NIC'

      def run
        validate_required_params(%i(datacenter_id server_id), config)

        nic_api = Ionoscloud::NicApi.new(api_client)
        @name_args.each do |nic_id|
          begin
            nic = nic_api.datacenters_servers_nics_find_by_id(config[:datacenter_id], config[:server_id], nic_id)
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("NIC ID #{nic_id} not found. Skipping.")
            next
          end

          msg_pair('ID', nic.id)
          msg_pair('Name', nic.properties.name)
          msg_pair('IPs', nic.properties.ips)
          msg_pair('DHCP', nic.properties.dhcp)
          msg_pair('LAN', nic.properties.lan)
          msg_pair('NAT', nic.properties.nat)

          begin
            confirm('Do you really want to delete this NIC')
          rescue SystemExit => exc
            next
          end

          nic_api.datacenters_servers_nics_delete(config[:datacenter_id], config[:server_id], nic.id)
          ui.warn("Deleted nic #{nic.id}")
        end
      end
    end
  end
end
