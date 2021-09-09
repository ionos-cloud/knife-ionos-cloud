require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudNodepoolLanAdd < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud nodepool lan add (options)'

      option :cluster_id,
              short: '-C CLUSTER_ID',
              long: '--cluster-id CLUSTER_ID',
              description: 'ID of the Kubernetes cluster'

      option :nodepool_id,
              short: '-N NODEPOOL_ID',
              long: '--nodepool NODEPOOL_ID',
              description: 'The ID of the K8s Nodepool'

      option :lan_id,
              short: '-L LAN_ID',
              long: '--lan LAN_ID',
              description: 'The ID of the LAN'

      option :no_dhcp,
              long: '--nodhcp',
              boolean: true,
              default: false,
              description: 'Indicates if the Kubernetes Node Pool LAN will reserve an IP using DHCP'

      option :routes,
              long: '--routes NETWORK,GATEWAY_IP [NETWORK,GATEWAY_IP]',
              description: 'An array of additional LANs attached to worker nodes'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Adds or updates a LAN within a Nodepool.'
        @required_options = [:cluster_id, :nodepool_id, :lan_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        kubernetes_api = Ionoscloud::KubernetesApi.new(api_client)

        begin
          nodepool = kubernetes_api.k8s_nodepools_find_by_id(config[:cluster_id], config[:nodepool_id])
        rescue Ionoscloud::ApiError => err
          raise err unless err.code == 404
          ui.error("Nodepool ID #{config[:nodepool_id]} not found.")
          exit(1)
        end

        routes = []
        config[:routes] = config[:routes].split(',') if config[:routes]
        config[:routes].each_slice(2) do |network, gateway_ip|
          routes << Ionoscloud::KubernetesNodePoolLanRoutes.new(
            network: network,
            gateway_ip: gateway_ip,
          )
        end

        new_lan = Ionoscloud::KubernetesNodePoolLan.new(
          id: Integer(config[:lan_id]),
          dhcp: !config[:no_dhcp],
          routes: routes,
        )

        puts new_lan

        existing = nodepool.properties.lans.select { |lan| lan.id == new_lan.id }

        new_nodepool = Ionoscloud::KubernetesNodePool.new(
          properties: Ionoscloud::KubernetesNodePoolPropertiesForPut.new(
            node_count: nodepool.properties.node_count,
            k8s_version: nodepool.properties.k8s_version,
            maintenance_window: nodepool.properties.maintenance_window,
            auto_scaling: nodepool.properties.auto_scaling,
            public_ips: nodepool.properties.public_ips,
            lans: nodepool.properties.lans,
          ),
        )

        new_nodepool.properties.lans = new_nodepool.properties.lans.delete_if { |lan| lan.id == new_lan.id }
        new_nodepool.properties.lans << new_lan

        nodepool = kubernetes_api.k8s_nodepools_put(
          config[:cluster_id], config[:nodepool_id], new_nodepool,
        )

        if existing.length > 0
          ui.info("Updating Lan #{config[:lan_id]} in the Nodepoool.")
        else
          ui.info("Adding Lan #{config[:lan_id]} to the Nodepoool.")
        end

        auto_scaling = "Min node count: #{nodepool.properties.auto_scaling.min_node_count}, Max node count:#{nodepool.properties.auto_scaling.max_node_count}"
        maintenance_window = "#{nodepool.properties.maintenance_window.day_of_the_week}, #{nodepool.properties.maintenance_window.time}"

        puts "\n"
        puts "#{ui.color('ID', :cyan)}: #{nodepool.id}"
        puts "#{ui.color('Name', :cyan)}: #{nodepool.properties.name}"
        puts "#{ui.color('K8s Version', :cyan)}: #{nodepool.properties.k8s_version}"
        puts "#{ui.color('Node Count', :cyan)}: #{nodepool.properties.node_count}"
        puts "#{ui.color('Lans', :cyan)}: #{nodepool.properties.lans.map do
          |lan|
          {
            id: lan.id,
            dhcp: lan.dhcp,
            routes: lan.routes ? lan.routes.map do
              |route|
              {
                network: route.network,
                gateway_ip: route.gateway_ip,
              }
            end : []
          }
        end}"
        puts "#{ui.color('Auto Scaling', :cyan)}: #{auto_scaling}"
        puts "#{ui.color('Maintenance Window', :cyan)}: #{maintenance_window}"
        puts "#{ui.color('State', :cyan)}: #{nodepool.metadata.state}"
        puts 'done'
      end
    end
  end
end
