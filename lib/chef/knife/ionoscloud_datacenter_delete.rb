require 'chef/knife/ionoscloud_base'

class Chef
  class Knife
    class IonoscloudDatacenterDelete < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud datacenter delete DATACENTER_ID [DATACENTER_ID]'

      def run
        datacenter_api = Ionoscloud::DataCenterApi.new(api_client)

        @name_args.each do |datacenter_id|
          begin
            datacenter = datacenter_api.datacenters_find_by_id(datacenter_id)
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("Data center ID #{datacenter_id} not found. Skipping.")
            next
          end

          msg_pair('ID', datacenter.id)
          msg_pair('Name', datacenter.properties.name)
          msg_pair('Description', datacenter.properties.description)
          msg_pair('Location', datacenter.properties.location)
          msg_pair('Version', datacenter.properties.version)

          puts "\n"

          begin
            confirm('Do you really want to delete this data center')
          rescue SystemExit => exc
            next
          end

          _, _, headers = datacenter_api.datacenters_delete_with_http_info(datacenter_id)
          ui.warn("Deleted Data center #{datacenter.id}. Request ID: #{get_request_id headers}")
        end
      end
    end
  end
end
