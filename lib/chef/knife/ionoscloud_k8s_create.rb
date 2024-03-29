require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudK8sCreate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud k8s create (options)'

      option :name,
              short: '-n NAME',
              long: '--name NAME',
              description: 'Name of the server'

      option :version,
              short: '-v VERSION',
              long: '--version VERSION',
              description: 'The version for the Kubernetes cluster.'

      option :private,
              long: '--private',
              default: false,
              description: 'The indicator if the cluster is public or private. Be aware that setting it to false is currently in beta phase.'

      option :gateway_ip,
              long: '--gateway GATEWAY_IP',
              description: 'The IP address of the gateway used by the cluster. This is mandatory when `public` is set to `false` and should not be provided otherwise.'

      option :maintenance_day,
              short: '-d MAINTENANCE_DAY',
              long: '--maintenance-day MAINTENANCE_DAY',
              description: 'Day Of the week when to perform the maintenance.'

      option :maintenance_time,
              short: '-t MAINTENANCE_TIME',
              long: '--maintenance-time MAINTENANCE_TIME',
              description: 'Time Of the day when to perform the maintenance.'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Creates a new Managed Kubernetes cluster.'
        @required_options = [:name, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        print "#{ui.color('Creating K8s Cluster...', :magenta)}"

        kubernetes_api = Ionoscloud::KubernetesApi.new(api_client)

        cluster_properties = {
          name: config[:name],
          k8sVersion: config[:version],
          public: !config[:private],
        }.compact

        if config[:private]
          if !config[:gateway_ip]
            ui.error("Gateway IP must be specified for private K8s Clusters")
            exit(1)
          end
          cluster_properties[:gatewayIp] = config[:gateway_ip]
        end

        if config[:maintenance_day] && config[:maintenance_time]
          cluster_properties[:maintenanceWindow] = {
            dayOfTheWeek: config[:maintenance_day],
            time: config[:maintenance_time],
          }
        end

        cluster, _, headers = kubernetes_api.k8s_post_with_http_info({ properties: cluster_properties })

        dot = ui.color('.', :magenta)
        api_client.wait_for { print dot; is_done? get_request_id headers }

        cluster = kubernetes_api.k8s_find_by_cluster_id(cluster.id)

        maintenance_window = "#{cluster.properties.maintenance_window.day_of_the_week}, #{cluster.properties.maintenance_window.time}"

        puts "\n"
        puts "#{ui.color('ID', :cyan)}: #{cluster.id}"
        puts "#{ui.color('Name', :cyan)}: #{cluster.properties.name}"
        puts "#{ui.color('k8s Version', :cyan)}: #{cluster.properties.k8s_version}"
        puts "#{ui.color('Maintenance Window', :cyan)}: #{maintenance_window}"
        puts "#{ui.color('State', :cyan)}: #{cluster.metadata.state}"

        puts 'done'
      end
    end
  end
end
