require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudLoadbalancerDelete < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud loadbalancer delete LOAD_BALANCER_ID [LOAD_BALANCER_ID] (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'Name of the data center'

      attr_reader :description, :required_options
      
      def initialize(args = [])
        super(args)
        @description =
        'Deletes the specified load balancer.'
        @required_options = [:datacenter_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        validate_required_params(@required_options, config)

        load_balancer_api = Ionoscloud::LoadBalancerApi.new(api_client)

        @name_args.each do |load_balancer_id|
          begin
            load_balancer = load_balancer_api.datacenters_loadbalancers_find_by_id(
              config[:datacenter_id],
              load_balancer_id,
              { depth: 1 },
            )
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("Load balancer ID #{load_balancer_id} not found. Skipping.")
            next
          end

          nics = load_balancer.entities.balancednics.items.map { |nic| nic.id }

          msg_pair('ID', load_balancer.id)
          msg_pair('Name', load_balancer.properties.name)
          msg_pair('IP address', load_balancer.properties.ip)
          msg_pair('DHCP', load_balancer.properties.dhcp)
          msg_pair('Balanced Nics', nics.to_s)

          puts "\n"

          begin
            confirm('Do you really want to delete this Load balancer')
          rescue SystemExit => exc
            next
          end

          _, _, headers = load_balancer_api.datacenters_loadbalancers_delete_with_http_info(
            config[:datacenter_id],
            load_balancer_id,
          )
          ui.warn("Deleted Load balancer #{load_balancer.id}. Request ID: #{get_request_id headers}")
        end
      end
    end
  end
end
