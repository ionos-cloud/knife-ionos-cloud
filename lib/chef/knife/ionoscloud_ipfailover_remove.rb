require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudIpfailoverRemove < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud ipfailover remove (options)'

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
              description: 'IP to be removed from the IP failover group'

      option :nic_id,
              short: '-n NIC_ID',
              long: '--nic-id NIC_ID',
              description: 'NIC to be removed from the IP failover group'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Remove IP Failover from LAN'
        @required_options = [:datacenter_id, :lan_id, :ip, :nic_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        lan_api = Ionoscloud::LansApi.new(api_client)

        lan = lan_api.datacenters_lans_find_by_id(config[:datacenter_id], config[:lan_id])

        initial_length = lan.properties.ip_failover.length

        changes = Ionoscloud::LanProperties.new(
          { ip_failover: lan.properties.ip_failover.select { |el| el.nic_uuid != config[:nic_id] || el.ip != config[:ip] } },
        )
        new_length = changes.ip_failover.length

        if new_length < initial_length
          _, _, headers = lan_api.datacenters_lans_patch_with_http_info(
            config[:datacenter_id], config[:lan_id], changes,
          )

          dot = ui.color('.', :magenta)
          api_client.wait_for { print dot; is_done? get_request_id headers }

          lan = lan_api.datacenters_lans_find_by_id(config[:datacenter_id], config[:lan_id])
        end

        ip_failovers = lan.properties.ip_failover.map { |el| el.to_hash }

        puts "\n"
        puts "#{ui.color('ID', :cyan)}: #{lan.id}"
        puts "#{ui.color('Name', :cyan)}: #{lan.properties.name}"
        puts "#{ui.color('Public', :cyan)}: #{lan.properties.public}"
        puts "#{ui.color('IP Failover', :cyan)}: #{ip_failovers}"
        puts 'done'
      end
    end
  end
end
