require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudFirewallCreate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud firewall create (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'ID of the data center'

      option :server_id,
              short: '-S SERVER_ID',
              long: '--server-id SERVER_ID',
              description: 'ID of the server'

      option :nic_id,
              short: '-N NIC_ID',
              long: '--nic-id NIC_ID',
              description: 'ID of the NIC'

      option :name,
              short: '-n NAME',
              long: '--name NAME',
              description: 'Name of the NIC'

      option :protocol,
              short: '-P PROTOCOL',
              long: '--protocol PROTOCOL',
              default: 'TCP',
              description: 'The protocol of the firewall rule (TCP, UDP, ICMP, ANY)'

      option :source_mac,
              short: '-m MAC',
              long: '--source-mac MAC',
              description: 'Only traffic originating from the respective MAC address is allowed'

      option :source_ip,
              short: '-I IP',
              long: '--source-ip IP',
              description: 'Only traffic originating from the respective IPv4' \
                          ' address is allowed; null allows all source IPs'

      option :target_ip,
              long: '--target-ip IP',
              description: 'In case the target NIC has multiple IP addresses,' \
                          ' only traffic directed to the respective IP' \
                          ' address of the NIC is allowed; null value allows' \
                          ' all target IPs'

      option :port_range_start,
              short: '-p PORT',
              long: '--port-range-start PORT',
              description: 'Defines the start range of the allowed port(s)'

      option :port_range_end,
              short: '-t PORT',
              long: '--port-range-end PORT',
              description: 'Defines the end range of the allowed port(s)'

      option :icmp_type,
              long: '--icmp-type INT',
              description: 'Defines the allowed type (from 0 to 254) if the' \
                          ' protocol ICMP is chosen; null allows all types'

      option :icmp_code,
              long: '--icmp-code INT',
              description: 'Defines the allowed code (from 0 to 254) if the' \
                          ' protocol ICMP is chosen; null allows all codes'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Creates a new firewall rule on an existing NIC.'
        @required_options = [:datacenter_id, :server_id, :nic_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        print "#{ui.color('Creating firewall...', :magenta)}"

        params = {
          name: config[:name],
          protocol: config[:protocol],
          source_mac: config[:source_mac],
          source_ip: config[:source_ip],
          target_ip: config[:target_ip],
          port_range_start: config[:port_range_start],
          port_range_end: config[:port_range_end],
          icmp_type: config[:icmp_type],
          icmp_code: config[:icmp_code],
        }

        nic_api = Ionoscloud::NicApi.new(api_client)

        firewall, _, headers = nic_api.datacenters_servers_nics_firewallrules_post_with_http_info(
          config[:datacenter_id],
          config[:server_id],
          config[:nic_id],
          Ionoscloud::FirewallRule.new({ properties: Ionoscloud::FirewallruleProperties.new(params.compact) }),
        )

        dot = ui.color('.', :magenta)
        api_client.wait_for { print dot; is_done? get_request_id headers }

        firewall = nic_api.datacenters_servers_nics_firewallrules_find_by_id(
          config[:datacenter_id],
          config[:server_id],
          config[:nic_id],
          firewall.id,
        )

        puts "\n"
        puts "#{ui.color('ID', :cyan)}: #{firewall.id}"
        puts "#{ui.color('Name', :cyan)}: #{firewall.properties.name}"
        puts "#{ui.color('Protocol', :cyan)}: #{firewall.properties.protocol}"
        puts "#{ui.color('Source MAC', :cyan)}: #{firewall.properties.source_mac}"
        puts "#{ui.color('Source IP', :cyan)}: #{firewall.properties.source_ip}"
        puts "#{ui.color('Target IP', :cyan)}: #{firewall.properties.target_ip}"
        puts "#{ui.color('Port Range Start', :cyan)}: #{firewall.properties.port_range_start}"
        puts "#{ui.color('Port Range End', :cyan)}: #{firewall.properties.port_range_end}"
        puts "#{ui.color('ICMP Type', :cyan)}: #{firewall.properties.icmp_type}"
        puts "#{ui.color('ICMP Code', :cyan)}: #{firewall.properties.icmp_code}"
        puts 'done'
      end
    end
  end
end
