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
              description: 'The IP address of the gateway used by the cluster. This is mandatory when `public` is set to `false` and should not be '
              'provided otherwise.'

      option :maintenance_day,
              short: '-d MAINTENANCE_DAY',
              long: '--maintenance-day MAINTENANCE_DAY',
              description: 'Day Of the week when to perform the maintenance.'

      option :maintenance_time,
              short: '-t MAINTENANCE_TIME',
              long: '--maintenance-time MAINTENANCE_TIME',
              description: 'Time Of the day when to perform the maintenance.'

      option :api_subnet_allow_list,
              long: '--subnets SUBNET [SUBNET]',
              description: 'Access to the K8s API server is restricted to these CIDRs. Cluster-internal traffic is not affected by this restriction. '\
              'If no allowlist is specified, access is not restricted. If an IP without subnet mask is provided, the default value will be used: 32 '\
              'for IPv4 and 128 for IPv6.'

      option :s3_buckets,
              long: '--buckets S3_BUCKET [S3_BUCKET]',
              description: 'List of S3 bucket configured for K8s usage. For now it contains only an S3 bucket used to store K8s API audit logs'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Creates a new Managed Kubernetes cluster.'
        @required_options = [:name, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        validate_required_params

        print "#{ui.color('Creating K8s Cluster...', :magenta)}"

        kubernetes_api = Ionoscloud::KubernetesApi.new(api_client)

        config[:api_subnet_allow_list] = config[:api_subnet_allow_list].split(',') if config[:api_subnet_allow_list]
        config[:s3_buckets] = config[:s3_buckets].split(',') if config[:s3_buckets]

        cluster_properties = {
          name: config[:name],
          k8s_version: config[:version],
          public: !config[:private],
          api_subnet_allow_list: config[:api_subnet_allow_list],
          s3_buckets: config[:s3_buckets],
        }.compact

        if config[:private]
          if !config[:gateway_ip]
            ui.error("Gateway IP must be specified for private K8s Clusters")
            exit(1)
          end
          cluster_properties[:gateway_ip] = config[:gateway_ip]
        end

        if config[:maintenance_day] && config[:maintenance_time]
          cluster_properties[:maintenance_window] = Ionoscloud::KubernetesMaintenanceWindow.new(
            day_of_the_week: config[:maintenance_day],
            time: config[:maintenance_time],
          )
        end

        k8s_cluster = Ionoscloud::KubernetesClusterForPost.new(
          properties: Ionoscloud::KubernetesClusterPropertiesForPost.new(
            **cluster_properties,
          ),
        )

        cluster, _, headers = kubernetes_api.k8s_post_with_http_info(k8s_cluster)

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
