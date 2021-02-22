require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudLoadbalancerNicRemove < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud loadbalancer nic remove NIC_ID [NIC_ID] (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'Name of the data center'

      option :loadbalancer_id,
              short: '-L LOADBALANCER_ID',
              long: '--loadbalancer-id LOADBALANCER_ID',
              description: 'Name of the load balancer'

      attr_reader :description, :required_options
      
      def initialize(args = [])
        super(args)
        @description =
        'Removes the association of a NIC with a load balancer.'
        @required_options = [:datacenter_id, :loadbalancer_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        validate_required_params(@required_options, config)

        load_balancer_api = Ionoscloud::LoadBalancerApi.new(api_client)

        request_ids_to_wait = []

        @name_args.each do |nic_id|
          begin
            _, _, headers = load_balancer_api.datacenters_loadbalancers_balancednics_delete_with_http_info(
              config[:datacenter_id],
              config[:loadbalancer_id],
              nic_id,
            )
            request_ids_to_wait.append(get_request_id headers)

            ui.warn("Removed NIC #{nic_id} from the Load balancer #{config[:loadbalancer_id]}. Request ID: #{get_request_id headers}.")
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("NIC ID #{nic_id} not found. Skipping.")
            next
          end
          
        end

        request_ids_to_wait.each { |request_id| api_client.wait_for {is_done? request_id}}

        load_balancer = load_balancer_api.datacenters_loadbalancers_find_by_id(
          config[:datacenter_id],
          config[:loadbalancer_id],
          { depth: 1 },
        )

        nics = load_balancer.entities.balancednics.items.map! {|el| el.id }

        puts "\n\n"
        puts "#{ui.color('ID', :cyan)}: #{load_balancer.id}"
        puts "#{ui.color('Name', :cyan)}: #{load_balancer.properties.name}"
        puts "#{ui.color('IP address', :cyan)}: #{load_balancer.properties.ip}"
        puts "#{ui.color('DHCP', :cyan)}: #{load_balancer.properties.dhcp}"
        puts "#{ui.color('NICs', :cyan)}: #{nics.to_s}"
        puts 'done'
      end
    end
  end
end
