require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudFirewallGet < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud firewall get (options)'

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

      option :firewall_id,
              short: '-F FIREWALL_ID',
              long: '--firewall-id FIREWALL_ID',
              description: 'ID of the Firewall Rule'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Retrieves information about a Ionoscloud Firewall Rule.'
        @required_options = [:firewall_id, :datacenter_id, :server_id, :nic_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        print_firewall_rule(Ionoscloud::NicApi.new(api_client).datacenters_servers_nics_firewallrules_find_by_id(
          config[:datacenter_id], config[:server_id], config[:nic_id], config[:firewall_id],
        ))
      end
    end
  end
end
