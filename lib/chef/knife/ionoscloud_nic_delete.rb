require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudNicDelete < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud nic delete NIC_ID [NIC_ID] (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'The ID of the data center'

      option :server_id,
              short: '-S SERVER_ID',
              long: '--server-id SERVER_ID',
              description: 'The ID of the server assigned the NIC'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Deletes an existing NIC from a server.'
        @required_options = [:datacenter_id, :server_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        validate_required_params(@required_options, config)

        nic_api = Ionoscloud::NicApi.new(api_client)
        @name_args.each do |nic_id|
          begin
            nic = nic_api.datacenters_servers_nics_find_by_id(config[:datacenter_id], config[:server_id], nic_id)
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("Nic ID #{nic_id} not found. Skipping.")
            next
          end

          msg_pair('ID', nic.id)
          msg_pair('Name', nic.properties.name)
          msg_pair('IPs', nic.properties.ips)
          msg_pair('DHCP', nic.properties.dhcp)
          msg_pair('LAN', nic.properties.lan)
          msg_pair('NAT', nic.properties.nat)

          begin
            confirm('Do you really want to delete this Nic')
          rescue SystemExit => exc
            next
          end

          _, _, headers = nic_api.datacenters_servers_nics_delete_with_http_info(config[:datacenter_id], config[:server_id], nic.id)
          ui.warn("Deleted Nic #{nic.id}. Request ID: #{get_request_id headers}")
        end
      end
    end
  end
end
