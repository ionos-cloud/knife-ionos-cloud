require 'chef/knife/ionoscloud_base'

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

      option :sourcemac,
              short: '-m MAC',
              long: '--source-mac MAC',
              description: 'Only traffic originating from the respective MAC address is allowed'

      option :sourceip,
              short: '-I IP',
              long: '--source-ip IP',
              description: 'Only traffic originating from the respective IPv4' \
                          ' address is allowed; null allows all source IPs'

      option :targetip,
              long: '--target-ip IP',
              description: 'In case the target NIC has multiple IP addresses,' \
                          ' only traffic directed to the respective IP' \
                          ' address of the NIC is allowed; null value allows' \
                          ' all target IPs'

      option :portrangestart,
              short: '-p PORT',
              long: '--port-range-start PORT',
              description: 'Defines the start range of the allowed port(s)'

      option :portrangeend,
              short: '-t PORT',
              long: '--port-range-end PORT',
              description: 'Defines the end range of the allowed port(s)'

      option :icmptype,
              long: '--icmp-type INT',
              description: 'Defines the allowed type (from 0 to 254) if the' \
                          ' protocol ICMP is chosen; null allows all types'

      option :icmpcode,
              long: '--icmp-code INT',
              description: 'Defines the allowed code (from 0 to 254) if the' \
                          ' protocol ICMP is chosen; null allows all codes'

      def run
        $stdout.sync = true
        validate_required_params(%i(datacenter_id server_id nic_id), config)

        print "#{ui.color('Creating firewall...', :magenta)}"
        
        params = {
          name: config[:name],
          protocol: config[:protocol],
          sourceMac: config[:sourcemac],
          sourceIp: config[:sourceip],
          targetIp: config[:targetip],
          portRangeStart: config[:portrangestart],
          portRangeEnd: config[:portrangeend],
          icmpType: config[:icmptype],
          icmpCode: config[:icmpcode],
        }

        nic_api = Ionoscloud::NicApi.new(api_client)

        firewall, _, headers = nic_api.datacenters_servers_nics_firewallrules_post_with_http_info(
          config[:datacenter_id],
          config[:server_id],
          config[:nic_id],
          { properties: params.compact },
        )

        dot = ui.color('.', :magenta)
        api_client.wait_for { print dot; is_done? get_request_id headers }

        firewall= nic_api.datacenters_servers_nics_firewallrules_find_by_id(
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
