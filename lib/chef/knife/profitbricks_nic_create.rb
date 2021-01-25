require 'chef/knife/profitbricks_base'

class Chef
  class Knife
    class ProfitbricksNicCreate < Knife
      include Knife::ProfitbricksBase

      banner 'knife profitbricks nic create (options)'

      option :datacenter_id,
             short: '-D DATACENTER_ID',
             long: '--datacenter-id DATACENTER_ID',
             description: 'Name of the data center'

      option :server_id,
             short: '-S SERVER_ID',
             long: '--server-id SERVER_ID',
             description: 'Name of the server'

      option :name,
             short: '-n NAME',
             long: '--name NAME',
             description: 'Name of the NIC'

      option :ips,
             short: '-i IP[,IP,...]',
             long: '--ips IP[,IP,...]',
             description: 'IPs assigned to the NIC',
             proc: proc { |ips| ips.split(',') }

      option :dhcp,
             short: '-d',
             long: '--dhcp',
             boolean: true | false,
             default: true,
             description: 'Set to false if you wish to disable DHCP'

      option :lan,
             short: '-l ID',
             long: '--lan ID',
             description: 'The LAN ID the NIC will reside on; if the LAN ID does not exist it will be created'

      option :nat,
             long: '--nat',
             boolean: true | false,
             description: 'Set to enable NAT on the NIC'

      def run
        $stdout.sync = true
        validate_required_params(%i(datacenter_id server_id lan), config)

        print "#{ui.color('Creating nic...', :magenta)}"

        params = {
          name: config[:name],
          ips: config[:ips],
          dhcp: config[:dhcp],
          lan: config[:lan],
        }

        if config[:nat]
          params[:nat] = config[:nat]
        end

        nic_api = Ionoscloud::NicApi.new(api_client)

        nic, _, headers = nic_api.datacenters_servers_nics_post_with_http_info(
          config[:datacenter_id],
          config[:server_id],
          { properties: params.compact },
        )

        request_id = headers['Location'].scan(%r{/requests/(\b[0-9a-f]{8}\b-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-\b[0-9a-f]{12}\b)}).last.first

        dot = ui.color('.', :magenta)
        api_client.wait_for { print dot; is_done? request_id }

        nic ic_api.datacenters_servers_nics_find_by_id(
          config[:datacenter_id],
          config[:server_id],
          nic.id,
        )

        puts "\n"
        puts "#{ui.color('ID', :cyan)}: #{nic.id}"
        puts "#{ui.color('Name', :cyan)}: #{nic.properties.name}"
        puts "#{ui.color('IPs', :cyan)}: #{nic.properties.ips}"
        puts "#{ui.color('DHCP', :cyan)}: #{nic.properties.dhcp}"
        puts "#{ui.color('LAN', :cyan)}: #{nic.properties.lan}"
        puts "#{ui.color('NAT', :cyan)}: #{nic.properties.nat}"

        puts 'done'
      end
    end
  end
end
