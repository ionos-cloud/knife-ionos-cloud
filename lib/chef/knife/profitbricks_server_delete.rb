require 'chef/knife/profitbricks_base'

class Chef
  class Knife
    class ProfitbricksServerDelete < Knife
      include Knife::ProfitbricksBase

      banner 'knife profitbricks server delete SERVER_ID [SERVER_ID] (options)'

      option :datacenter_id,
             short: '-D DATACENTER_ID',
             long: '--datacenter-id DATACENTER_ID',
             description: 'Name of the data center'

      def run
        server_api = Ionoscloud::ServerApi.new(api_client)

        @name_args.each do |server_id|
          begin
            server = server_api.datacenters_servers_find_by_id(config[:datacenter_id], server_id)
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("Server ID #{server_id} not found. Skipping.")
            next
          end

          msg_pair('ID', server.id)
          msg_pair('Name', server.properties.name)
          msg_pair('Cores', server.properties.cores)
          msg_pair('RAM', server.properties.ram)
          msg_pair('Availability Zone', server.properties.availability_zone)

          begin
            confirm('Do you really want to delete this server')
          rescue SystemExit => exc
            next
          end

          _, _, headers = server_api.datacenters_servers_delete_with_http_info(config[:datacenter_id], server_id)
          ui.warn("Deleted server #{server.id}. Request ID: #{get_request_id headers}")
        end
      end
    end
  end
end
