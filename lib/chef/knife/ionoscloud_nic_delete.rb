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

      def initialize(args = [])
        super(args)
        @description =
        'Deletes an existing NIC from a server.'
        @directory = 'compute-engine'
        @required_options = [:datacenter_id, :server_id]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        nic_api = Ionoscloud::NetworkInterfacesApi.new(api_client)
        @name_args.each do |nic_id|
          begin
            nic = nic_api.datacenters_servers_nics_find_by_id(config[:datacenter_id], config[:server_id], nic_id)
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("Nic ID #{nic_id} not found. Skipping.")
            next
          end

          print_nic(nic)
          puts "\n"

          begin
            confirm('Do you really want to delete this Nic')
          rescue SystemExit
            next
          end

          _, _, headers = nic_api.datacenters_servers_nics_delete_with_http_info(config[:datacenter_id], config[:server_id], nic.id)
          ui.warn("Deleted Nic #{nic.id}. Request ID: #{get_request_id headers}")
        end
      end
    end
  end
end
