require 'chef/knife/ionoscloud_base'

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

      option :maintenanceday,
             short: '-d MAINTENANCE_DAY',
             long: '--maintenance-day MAINTENANCE_DAY',
             description: 'Day Of the week when to perform the maintenance.'

      option :maintenancetime,
             short: '-t MAINTENANCE_TIME',
             long: '--maintenance-time MAINTENANCE_TIME',
             description: 'Time Of the day when to perform the maintenance.'


      def run
        $stdout.sync = true
        validate_required_params(%i(name), config)

        print "#{ui.color('Creating K8s Cluster...', :magenta)}"

        kubernetes_api = Ionoscloud::KubernetesApi.new(api_client)

        cluster_properties = {
          name: config[:name],
          k8sVersion: config[:version],
        }.compact

        if config[:maintenanceday] && config[:maintenancetime]
          cluster_properties[:maintenanceWindow] = {
            dayOfTheWeek: config[:maintenanceday],
            time: config[:maintenancetime],
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
