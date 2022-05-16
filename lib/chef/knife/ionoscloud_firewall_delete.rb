require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudFirewallDelete < Knife
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

      def initialize(args = [])
        super(args)
        @description =
        'Deletes a firewall rule from an existing NIC.'
        @directory = 'compute-engine'
        @required_options = [:datacenter_id, :server_id, :nic_id]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        firewallrules_api = Ionoscloud::FirewallRulesApi.new(api_client)

        @name_args.each do |firewall_id|
          begin
            firewall = firewallrules_api.datacenters_servers_nics_firewallrules_find_by_id(
              config[:datacenter_id], config[:server_id], config[:nic_id], firewall_id,
            )
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("Firewall rule ID #{firewall_id} not found. Skipping.")
            next
          end

          print_firewall_rule(firewall)
          puts "\n"

          begin
            confirm('Do you really want to delete this firewall rule')
          rescue SystemExit
            next
          end

          _, _, headers = firewallrules_api.datacenters_servers_nics_firewallrules_delete_with_http_info(
            config[:datacenter_id], config[:server_id], config[:nic_id], firewall_id,
          )
          ui.warn("Deleted Firewall rule #{firewall.id}. Request ID: #{get_request_id headers}")
        end
      end
    end
  end
end
