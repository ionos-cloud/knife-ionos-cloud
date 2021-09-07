require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudK8sUpdate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud k8s update (options)'

      option :cluster_id,
              short: '-C CLUSTER_ID',
              long: '--cluster-id CLUSTER_ID',
              description: 'ID of the Kubernetes cluster'

      option :name,
              short: '-n NAME',
              long: '--name NAME',
              description: 'Name of the server'

      option :version,
              short: '-v VERSION',
              long: '--version VERSION',
              description: 'The version for the Kubernetes cluster.'

      option :maintenance_day,
              long: '--maintenance-day MAINTENANCE_DAY',
              description: 'Day Of the week when to perform the maintenance.'

      option :maintenance_time,
              short: '-t MAINTENANCE_TIME',
              long: '--maintenance-time MAINTENANCE_TIME',
              description: 'Time Of the day when to perform the maintenance.'

      option :api_subnet_allow_list,
              long: '--subnets SUBNET[,SUBNET,...]',
              description: 'Access to the K8s API server is restricted to these CIDRs. Cluster-internal traffic is not affected by this '\
              'restriction. If no allowlist is specified, access is not restricted. If an IP without subnet mask is provided, the default '\
              'value will be used: 32 for IPv4 and 128 for IPv6.'

      option :s3_buckets,
              long: '--s3-buckets BUCKET[,BUCKET,...]',
              description: 'List of S3 bucket configured for K8s usage. For now it contains only one S3 bucket used to store K8s API audit logs.'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Updates information about a Ionoscloud K8s Cluster.'
        @required_options = [:cluster_id, :ionoscloud_username, :ionoscloud_password]
        @updatable_fields = [
          :name, :version, :maintenance_day, :maintenance_time, :api_subnet_allow_list, :s3_buckets,
        ]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        kubernetes_api = Ionoscloud::KubernetesApi.new(api_client)

        if @updatable_fields.map { |el| config[el] }.any?
          print "#{ui.color('Updating K8s Cluster...', :magenta)}"

          if config[:api_subnet_allow_list] && config[:api_subnet_allow_list].instance_of?(String)
            config[:api_subnet_allow_list] = config[:api_subnet_allow_list].split(',')
          end
          config[:s3_buckets] = config[:s3_buckets].split(',') if config[:s3_buckets] && config[:s3_buckets].instance_of?(String)

          if config.key?(:s3_buckets)
            config[:s3_buckets] = config[:s3_buckets].map { |el| Ionoscloud::S3Bucket.new(name: el) }
          end

          cluster = kubernetes_api.k8s_find_by_cluster_id(config[:cluster_id])
          
          new_cluster = Ionoscloud::KubernetesCluster.new(
            properties: Ionoscloud::KubernetesClusterPropertiesForPut.new(
              name: config.key?(:name) ? config[:name] : cluster.properties.name,
              k8s_version: config.key?(:version) ? config[:version] : cluster.properties.k8s_version,
              maintenance_window: Ionoscloud::KubernetesMaintenanceWindow.new(
                day_of_the_week: config.key?(:maintenance_day) ? config[:maintenance_day] : cluster.properties.maintenance_window.day_of_the_week,
                time: config.key?(:maintenance_time) ? config[:maintenance_time] : cluster.properties.maintenance_window.time,
              ),
              api_subnet_allow_list: config.key?(:api_subnet_allow_list) ? config[:api_subnet_allow_list] : cluster.properties.api_subnet_allow_list,
              s3_buckets: config.key?(:s3_buckets) ? config[:s3_buckets] : cluster.properties.s3_buckets,
            ),
          )

          kubernetes_api.k8s_put(config[:cluster_id], new_cluster)
        else
          ui.warn("Nothing to update, please set one of the attributes #{@updatable_fields}.")
        end

        print_k8s_cluster(kubernetes_api.k8s_find_by_cluster_id(config[:cluster_id]))
      end
    end
  end
end
