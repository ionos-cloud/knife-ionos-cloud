require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudIpfailoverAdd < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud ipfailover add (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'Name of the data center'

      option :lan_id,
              short: '-l LAN_ID',
              long: '--lan-id LAN_ID',
              description: 'Lan ID'

      option :ip,
              short: '-i IP',
              long: '--ip IP',
              description: 'IP to be added to IP failover group'

      option :nic_id,
              short: '-n NIC_ID',
              long: '--nic-id NIC_ID',
              description: 'NIC to be added to IP failover group'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        "Successfully setting up an IP Failover group requires three steps:\n"\
        "* Add a reserved IP address to a NIC that will become the IP Failover master.\n"\
        "* Use PATCH or PUT to enable ipFailover by providing the relevant ip and nicUuid values.\n"\
        "* Add the same reserved IP address to any other NICs that are a member of the same LAN. Those NICs will become IP Failover members.\n"
        @required_options = [:datacenter_id, :lan_id, :ip, :nic_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        lan_api = Ionoscloud::LanApi.new(api_client)

        lan = lan_api.datacenters_lans_find_by_id(config[:datacenter_id], config[:lan_id])

        failover_ips = lan.properties.ip_failover || []
        failover_ips.push(
          Ionoscloud::IPFailover.new(
            ip: config[:ip],
            nic_uuid: config[:nic_id],
          ),
        )

        changes = Ionoscloud::LanProperties.new({ ip_failover: failover_ips })

        _, _, headers = lan_api.datacenters_lans_patch_with_http_info(config[:datacenter_id], config[:lan_id], changes)

        dot = ui.color('.', :magenta)
        api_client.wait_for { print dot; is_done? get_request_id headers }

        print_lan(lan_api.datacenters_lans_find_by_id(config[:datacenter_id], config[:lan_id]))
      end
    end
  end
end
