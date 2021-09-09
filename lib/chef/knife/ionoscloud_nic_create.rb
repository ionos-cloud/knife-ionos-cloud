require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudNicCreate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud nic create (options)'

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
              description: 'IPs assigned to the NIC'

      option :dhcp,
              long: '--dhcp DHCP',
              description: 'Set to false if you wish to disable DHCP'

      option :lan,
              short: '-l ID',
              long: '--lan ID',
              description: 'The LAN ID the NIC will reside on; if the LAN ID does not exist it will be created'

      option :nat,
              long: '--nat NAT',
              description: 'Set to enable NAT on the NIC'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        "Creates a NIC on the specified server. The Ionoscloud platform supports adding multiple NICs to a server. These NICs "\
        "can be used to create different, segmented networks on the platform."
        @required_options = [:datacenter_id, :server_id, :lan, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        print "#{ui.color('Creating nic...', :magenta)}"

        config[:ips] = config[:ips].split(',') if config[:ips] && config[:ips].instance_of?(String)

        nic_api = Ionoscloud::NicApi.new(api_client)

        nic, _, headers = nic_api.datacenters_servers_nics_post_with_http_info(
          config[:datacenter_id],
          config[:server_id],
          Ionoscloud::Nic.new(
            properties: Ionoscloud::NicProperties.new(
              name: config[:name],
              ips: config[:ips],
              dhcp: (config.key?(:dhcp) ? config[:dhcp].to_s.downcase == 'true' : nil),
              lan: config[:lan],
              nat: (config.key?(:nat) ? config[:nat].to_s.downcase == 'true' : nil),
            ),
          ),
        )

        dot = ui.color('.', :magenta)
        api_client.wait_for { print dot; is_done? get_request_id headers }

        print_nic(nic_api.datacenters_servers_nics_find_by_id(
                    config[:datacenter_id],
          config[:server_id],
          nic.id,
        ))
      end
    end
  end
end
