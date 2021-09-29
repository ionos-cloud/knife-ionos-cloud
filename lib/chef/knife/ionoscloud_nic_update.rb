require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudNicUpdate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud nic update (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'ID of the data center'

      option :server_id,
              short: '-S SERVER_ID',
              long: '--server-id SERVER_ID',
              description: 'The ID of the server to which the NIC is assigned'

      option :nic_id,
              short: '-N NIC_ID',
              long: '--nic-id NIC_ID',
              description: 'ID of the load balancer'

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


      option :firewall_type,
              short: '-t FIREWALL_TYPE',
              long: '--firewall-type FIREWALL_TYPE',
              description: 'The type of firewall rules that will be allowed on the NIC. If it is not specified it will take the '\
              'default value INGRESS'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Updates information about a Ionoscloud NIC.'
        @required_options = [:datacenter_id, :server_id, :nic_id, :ionoscloud_username, :ionoscloud_password]
        @updatable_fields = [:name, :ips, :dhcp, :lan, :nat]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        config[:ips] = config[:ips].split(',') if config[:ips] && config[:ips].instance_of?(String)

        nic_api = Ionoscloud::NetworkInterfacesApi.new(api_client)

        if @updatable_fields.map { |el| config[el] }.any?
          print "#{ui.color('Updating NIC...', :magenta)}"

          _, _, headers  = nic_api.datacenters_servers_nics_patch_with_http_info(
            config[:datacenter_id],
            config[:server_id],
            config[:nic_id],
            Ionoscloud::NicProperties.new(
              name: config[:name],
              ips: config[:ips],
              dhcp: (config.key?(:dhcp) ? config[:dhcp].to_s.downcase == 'true' : nil),
              lan: config[:lan],
              firewall_type: config[:firewall_type],
            ),
          )

          dot = ui.color('.', :magenta)
          api_client.wait_for { print dot; is_done? get_request_id headers }
        else
          ui.warn("Nothing to update, please set one of the attributes #{@updatable_fields}.")
        end

        print_nic(nic_api.datacenters_servers_nics_find_by_id(config[:datacenter_id], config[:server_id], config[:nic_id]))
      end
    end
  end
end
