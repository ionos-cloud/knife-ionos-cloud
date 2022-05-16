require 'chef/knife'

require 'knife-ionoscloud/version'


MODULE_VERSION = Knife::Ionoscloud::VERSION unless defined? MODULE_VERSION

class Chef
  class Knife
    module IonoscloudBase
      def initialize(args = [])
        super(args)
        @description = ''
        @directory = ''
        @required_options = []
      end

      attr_reader :description, :required_options, :directory

      def self.included(includer)
        includer.class_eval do
          deps do
            warn_level = $VERBOSE
            $VERBOSE = nil
            require 'ionoscloud'
            require 'ionoscloud-dbaas-postgres'
            $VERBOSE = warn_level
          end

          option :ionoscloud_username,
                  short: '-u USERNAME',
                  long: '--username USERNAME',
                  description: 'Your Ionoscloud username'

          option :ionoscloud_password,
                  short: '-p PASSWORD',
                  long: '--password PASSWORD',
                  description: 'Your Ionoscloud password'

          option :ionoscloud_url,
                  long: '--url URL',
                  description: 'The Ionoscloud API URL'

          option :extra_config_file,
                  short: '-e EXTRA_CONFIG_FILE_PATH',
                  long: '--extra-config EXTRA_CONFIG_FILE_PATH',
                  description: 'Path to the additional config file'
        end
      end

      def msg_pair(label, value, color = :cyan)
        if !value.nil? && !value.to_s.empty?
          puts "#{ui.color(label, color)}: #{value}"
        end
      end

      def validate_required_params(required_params, params)
        missing_params = required_params.select do |param|
          params[param].nil?
        end
        if missing_params.any?
          puts "Missing required parameters #{missing_params}"
          exit(1)
        end
      end

      def handle_extra_config
        return if config[:extra_config_file].nil?

        available_options = options.map { |key, _| key }
        ionoscloud_options = available_options[available_options.find_index(:ionoscloud_username)..]
        ignored_options = []

        JSON[File.read(config[:extra_config_file])].transform_keys(&:to_sym).each do |key, value|
          if config.key?(key) || !ionoscloud_options.include?(key)
            ignored_options << key
          else
            config[key] = value 
          end
        end

        ui.warn "The following options #{ignored_options} from the specified JSON file will be ignored." unless ignored_options.empty?
      end

      def api_client
        return @api_client if @api_client

        api_config = Ionoscloud::Configuration.new()

        api_config.username = config[:ionoscloud_username]
        api_config.password = config[:ionoscloud_password]

        if config[:ionoscloud_url]
          uri = URI.parse(config[:ionoscloud_url])

          api_config.scheme = uri.scheme
          api_config.host = uri.host
          api_config.base_path = uri.path
          api_config.server_index = nil
        end

        api_config.debugging = config[:ionoscloud_debug] || false

        @api_client = Ionoscloud::ApiClient.new(api_config)

        @api_client.user_agent =  [
          'knife/v' + MODULE_VERSION,
          @api_client.default_headers['User-Agent'],
          'chef/' + Chef::VERSION,
        ].join('_')

        @api_client
      end

      def api_client_dbaas
        return @api_client_dbaas if @api_client_dbaas

        api_config_dbaas = IonoscloudDbaasPostgres::Configuration.new()

        api_config_dbaas.username = config[:ionoscloud_username]
        api_config_dbaas.password = config[:ionoscloud_password]

        api_config_dbaas.debugging = config[:ionoscloud_debug] || false

        @api_client_dbaas = IonoscloudDbaasPostgres::ApiClient.new(api_config_dbaas)

        @api_client_dbaas.user_agent =  [
          'knife/v' + MODULE_VERSION,
          @api_client_dbaas.default_headers['User-Agent'],
          'chef/' + Chef::VERSION,
        ].join('_')

        @api_client_dbaas
      end

      def get_request_id(headers)
        begin
          headers['Location'].scan(%r{/requests/(\b[0-9a-f]{8}\b-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-\b[0-9a-f]{12}\b)}).last.first
        rescue NoMethodError
          nil
        end
      end

      def is_done?(request_id)
        response = Ionoscloud::RequestsApi.new(api_client).requests_status_get(request_id)
        if response.metadata.status == 'FAILED'
          puts "\nRequest #{request_id} failed\n#{response.metadata.message.to_s}"
          exit(1)
        end
        response.metadata.status == 'DONE'
      end

      def print_datacenter(datacenter)
        print "\n"
        cpu_architecture = datacenter.properties.cpu_architecture.nil? ? [] : datacenter.properties.cpu_architecture.map { |arch| arch.to_hash }
        puts "#{ui.color('ID', :cyan)}: #{datacenter.id}"
        puts "#{ui.color('Name', :cyan)}: #{datacenter.properties.name}"
        puts "#{ui.color('Description', :cyan)}: #{datacenter.properties.description}"
        puts "#{ui.color('Location', :cyan)}: #{datacenter.properties.location}"
        puts "#{ui.color('Version', :cyan)}: #{datacenter.properties.version}"
        puts "#{ui.color('Features', :cyan)}: #{datacenter.properties.features}"
        puts "#{ui.color('CPU Architecture', :cyan)}: #{cpu_architecture}"
        puts "#{ui.color('Sec Auth Protection', :cyan)}: #{datacenter.properties.sec_auth_protection}"
      end

      def print_backupunit(backupunit)
        print "\n"
        puts "#{ui.color('ID', :cyan)}: #{backupunit.id}"
        puts "#{ui.color('Name', :cyan)}: #{backupunit.properties.name}"
        puts "#{ui.color('Email', :cyan)}: #{backupunit.properties.email}"
      end

      def print_firewall_rule(firewall)
        print "\n"
        puts "#{ui.color('ID', :cyan)}: #{firewall.id}"
        puts "#{ui.color('Name', :cyan)}: #{firewall.properties.name}"
        puts "#{ui.color('Type', :cyan)}: #{firewall.properties.type}"
        puts "#{ui.color('Protocol', :cyan)}: #{firewall.properties.protocol}"
        puts "#{ui.color('Source MAC', :cyan)}: #{firewall.properties.source_mac}"
        puts "#{ui.color('Source IP', :cyan)}: #{firewall.properties.source_ip}"
        puts "#{ui.color('Target IP', :cyan)}: #{firewall.properties.target_ip}"
        puts "#{ui.color('Port Range Start', :cyan)}: #{firewall.properties.port_range_start}"
        puts "#{ui.color('Port Range End', :cyan)}: #{firewall.properties.port_range_end}"
        puts "#{ui.color('ICMP Type', :cyan)}: #{firewall.properties.icmp_type}"
        puts "#{ui.color('ICMP Code', :cyan)}: #{firewall.properties.icmp_code}"
      end

      def print_group(group)
        print "\n"
        puts "#{ui.color('ID', :cyan)}: #{group.id}"
        puts "#{ui.color('Name', :cyan)}: #{group.properties.name}"
        puts "#{ui.color('Create Datacenter', :cyan)}: #{group.properties.create_data_center.to_s}"
        puts "#{ui.color('Create Snapshot', :cyan)}: #{group.properties.create_snapshot.to_s}"
        puts "#{ui.color('Reserve IP', :cyan)}: #{group.properties.reserve_ip.to_s}"
        puts "#{ui.color('Access Activity Log', :cyan)}: #{group.properties.access_activity_log.to_s}"
        puts "#{ui.color('S3 Privilege', :cyan)}: #{group.properties.s3_privilege.to_s}"
        puts "#{ui.color('Create Backup Unit', :cyan)}: #{group.properties.create_backup_unit.to_s}"
        puts "#{ui.color('Create K8s Clusters', :cyan)}: #{group.properties.create_k8s_cluster.to_s}"
        puts "#{ui.color('Create PCC', :cyan)}: #{group.properties.create_pcc.to_s}"
        puts "#{ui.color('Create Internet Acess', :cyan)}: #{group.properties.create_internet_access.to_s}"
        puts "#{ui.color('Create Flow Logs', :cyan)}: #{group.properties.create_flow_log.to_s}"
        puts "#{ui.color('Access and Manage Monitoring', :cyan)}: #{group.properties.access_and_manage_monitoring.to_s}"
        puts "#{ui.color('Access and Manage Certificates', :cyan)}: #{group.properties.access_and_manage_certificates.to_s}"

        puts "#{ui.color('Users', :cyan)}: #{(group.entities.users.items.map { |el| el.id }).to_s}" unless group.entities.users.items.nil?
      end

      def print_ipblock(ipblock)
        print "\n"
        ip_consumers = (ipblock.properties.ip_consumers.nil? ? [] : ipblock.properties.ip_consumers.map { |el| el.to_hash })
        puts "#{ui.color('ID', :cyan)}: #{ipblock.id}"
        puts "#{ui.color('Name', :cyan)}: #{ipblock.properties.name}"
        puts "#{ui.color('Location', :cyan)}: #{ipblock.properties.location}"
        puts "#{ui.color('IP Addresses', :cyan)}: #{ipblock.properties.ips}"
        puts "#{ui.color('IP Consumers', :cyan)}: #{ip_consumers}"
      end

      def print_k8s_cluster(cluster)
        print "\n"
        maintenance_window = "#{cluster.properties.maintenance_window.day_of_the_week}, #{cluster.properties.maintenance_window.time}"
        s3_buckets = (cluster.properties.s3_buckets.nil? ? [] : cluster.properties.s3_buckets.map { |el| el.name })
        puts "#{ui.color('ID', :cyan)}: #{cluster.id}"
        puts "#{ui.color('Name', :cyan)}: #{cluster.properties.name}"
        puts "#{ui.color('k8s Version', :cyan)}: #{cluster.properties.k8s_version}"
        puts "#{ui.color('Maintenance Window', :cyan)}: #{maintenance_window}"
        puts "#{ui.color('State', :cyan)}: #{cluster.metadata.state}"
        puts "#{ui.color('Api Subnet Allow List', :cyan)}: #{cluster.properties.api_subnet_allow_list}"
        puts "#{ui.color('S3 Buckets', :cyan)}: #{s3_buckets}"
        puts "#{ui.color('Available Upgrade Versions', :cyan)}: #{cluster.properties.available_upgrade_versions}"
        puts "#{ui.color('Viable NodePool Versions', :cyan)}: #{cluster.properties.viable_node_pool_versions}"
      end

      def print_lan(lan)
        print "\n"
        ip_failovers = (lan.properties.ip_failover.nil? ? [] : lan.properties.ip_failover.map { |el| el.to_hash })
        puts "#{ui.color('ID', :cyan)}: #{lan.id}"
        puts "#{ui.color('Name', :cyan)}: #{lan.properties.name}"
        puts "#{ui.color('Public', :cyan)}: #{lan.properties.public}"
        puts "#{ui.color('PCC', :cyan)}: #{lan.properties.pcc}"
        puts "#{ui.color('IP Failover', :cyan)}: #{ip_failovers}"
      end

      def print_load_balancer(load_balancer)
        print "\n"
        nics = load_balancer.entities.balancednics.items.map! { |el| el.id }
        puts "#{ui.color('ID', :cyan)}: #{load_balancer.id}"
        puts "#{ui.color('Name', :cyan)}: #{load_balancer.properties.name}"
        puts "#{ui.color('IP address', :cyan)}: #{load_balancer.properties.ip}"
        puts "#{ui.color('DHCP', :cyan)}: #{load_balancer.properties.dhcp}"
        puts "#{ui.color('Balanced Nics', :cyan)}: #{nics.to_s}"
      end

      def print_nic(nic)
        print "\n"
        puts "#{ui.color('ID', :cyan)}: #{nic.id}"
        puts "#{ui.color('Name', :cyan)}: #{nic.properties.name}"
        puts "#{ui.color('IPs', :cyan)}: #{nic.properties.ips.to_s}"
        puts "#{ui.color('DHCP', :cyan)}: #{nic.properties.dhcp}"
        puts "#{ui.color('LAN', :cyan)}: #{nic.properties.lan}"
        puts "#{ui.color('Firewall Type', :cyan)}: #{nic.properties.firewall_type}"
        puts "#{ui.color('Device Number', :cyan)}: #{nic.properties.device_number}"
        puts "#{ui.color('PCI Slot', :cyan)}: #{nic.properties.pci_slot}"
      end

      def print_k8s_node(node)
        print "\n"
        puts "#{ui.color('ID', :cyan)}: #{node.id}"
        puts "#{ui.color('Name', :cyan)}: #{node.properties.name}"
        puts "#{ui.color('Public IP', :cyan)}: #{node.properties.public_ip}"
        puts "#{ui.color('Private IP', :cyan)}: #{node.properties.private_ip}"
        puts "#{ui.color('K8s Version', :cyan)}: #{node.properties.k8s_version}"
        puts "#{ui.color('State', :cyan)}: #{node.metadata.state}"
      end

      def print_k8s_nodepool(nodepool)
        print "\n"
        auto_scaling = "Min node count: #{nodepool.properties.auto_scaling.min_node_count}, Max node count:#{nodepool.properties.auto_scaling.max_node_count}"
        maintenance_window = "#{nodepool.properties.maintenance_window.day_of_the_week}, #{nodepool.properties.maintenance_window.time}"
        lans = nodepool.properties.lans.map { |lan| lan.to_hash }
        puts "#{ui.color('ID', :cyan)}: #{nodepool.id}"
        puts "#{ui.color('Name', :cyan)}: #{nodepool.properties.name}"
        puts "#{ui.color('K8s Version', :cyan)}: #{nodepool.properties.k8s_version}"
        puts "#{ui.color('Datacenter ID', :cyan)}: #{nodepool.properties.datacenter_id}"
        puts "#{ui.color('Node Count', :cyan)}: #{nodepool.properties.node_count}"
        puts "#{ui.color('CPU Family', :cyan)}: #{nodepool.properties.cpu_family}"
        puts "#{ui.color('Cores Count', :cyan)}: #{nodepool.properties.cores_count}"
        puts "#{ui.color('RAM', :cyan)}: #{nodepool.properties.ram_size}"
        puts "#{ui.color('Storage Type', :cyan)}: #{nodepool.properties.storage_type}"
        puts "#{ui.color('Storage Size', :cyan)}: #{nodepool.properties.storage_size}"
        puts "#{ui.color('Public IPs', :cyan)}: #{nodepool.properties.public_ips}"
        puts "#{ui.color('Labels', :cyan)}: #{nodepool.properties.labels}"
        puts "#{ui.color('Annotations', :cyan)}: #{nodepool.properties.annotations}"
        puts "#{ui.color('LANs', :cyan)}: #{lans}"
        puts "#{ui.color('Availability Zone', :cyan)}: #{nodepool.properties.availability_zone}"
        puts "#{ui.color('Auto Scaling', :cyan)}: #{auto_scaling}"
        puts "#{ui.color('Maintenance Window', :cyan)}: #{maintenance_window}"
        puts "#{ui.color('State', :cyan)}: #{nodepool.metadata.state}"
      end

      def print_pcc(pcc)
        peers = pcc.properties.peers.map { |peer| peer.id }
        datacenters = pcc.properties.connectable_datacenters.map { |datacenter| datacenter.id }
        print "\n"
        puts "#{ui.color('ID', :cyan)}: #{pcc.id}"
        puts "#{ui.color('Name', :cyan)}: #{pcc.properties.name}"
        puts "#{ui.color('Description', :cyan)}: #{pcc.properties.description}"
        puts "#{ui.color('Peers', :cyan)}: #{peers}"
        puts "#{ui.color('Connectable Datacenters', :cyan)}: #{datacenters}"
      end

      def print_s3key(s3_key)
        print "\n"
        puts "#{ui.color('ID', :cyan)}: #{s3_key.id}"
        puts "#{ui.color('Secret Key', :cyan)}: #{s3_key.properties.secret_key}"
        puts "#{ui.color('Active', :cyan)}: #{s3_key.properties.active}"
      end

      def print_server(server)
        print "\n"
        puts "#{ui.color('ID', :cyan)}: #{server.id}"
        puts "#{ui.color('Name', :cyan)}: #{server.properties.name}"
        puts "#{ui.color('Type', :cyan)}: #{server.properties.type}"
        puts "#{ui.color('Template', :cyan)}: #{server.properties.template_uuid}"
        puts "#{ui.color('Cores', :cyan)}: #{server.properties.cores}"
        puts "#{ui.color('CPU Family', :cyan)}: #{server.properties.cpu_family}"
        puts "#{ui.color('Ram', :cyan)}: #{server.properties.ram}"
        puts "#{ui.color('Availability Zone', :cyan)}: #{server.properties.availability_zone}"
        puts "#{ui.color('VM State', :cyan)}: #{server.properties.vm_state}"
        puts "#{ui.color('Boot Volume', :cyan)}: #{server.properties.boot_volume ? server.properties.boot_volume.id : ''}"
        puts "#{ui.color('Boot CDROM', :cyan)}: #{server.properties.boot_cdrom ? server.properties.boot_cdrom.id : ''}"
      end

      def print_share(share)
        print "\n"
        puts "#{ui.color('ID', :cyan)}: #{share.id}"
        puts "#{ui.color('Edit Privilege', :cyan)}: #{share.properties.edit_privilege.to_s}"
        puts "#{ui.color('Share Privilege', :cyan)}: #{share.properties.share_privilege.to_s}"
      end

      def print_snapshot(snapshot)
        print "\n"
        puts "#{ui.color('ID', :cyan)}: #{snapshot.id}"
        puts "#{ui.color('Name', :cyan)}: #{snapshot.properties.name}"
        puts "#{ui.color('Description', :cyan)}: #{snapshot.properties.description}"
        puts "#{ui.color('Location', :cyan)}: #{snapshot.properties.location}"
        puts "#{ui.color('Size', :cyan)}: #{snapshot.properties.size.to_s}"
        puts "#{ui.color('Sec Auth Protection', :cyan)}: #{snapshot.properties.sec_auth_protection}"
        puts "#{ui.color('License Type', :cyan)}: #{snapshot.properties.licence_type}"

        puts "#{ui.color('CPU Hot Plug', :cyan)}: #{snapshot.properties.cpu_hot_plug}"
        puts "#{ui.color('CPU Hot Unplug', :cyan)}: #{snapshot.properties.cpu_hot_unplug}"

        puts "#{ui.color('RAM Hot Plug', :cyan)}: #{snapshot.properties.ram_hot_plug}"
        puts "#{ui.color('RAM Hot Unplug', :cyan)}: #{snapshot.properties.ram_hot_unplug}"

        puts "#{ui.color('NIC Hot Plug', :cyan)}: #{snapshot.properties.nic_hot_plug}"
        puts "#{ui.color('NIC Hot Unplug', :cyan)}: #{snapshot.properties.nic_hot_unplug}"

        puts "#{ui.color('Disc Virtio Hot Plug', :cyan)}: #{snapshot.properties.disc_virtio_hot_plug}"
        puts "#{ui.color('Disc Virtio Hot Unplug', :cyan)}: #{snapshot.properties.disc_virtio_hot_unplug}"

        puts "#{ui.color('Disc Scsi Hot Plug', :cyan)}: #{snapshot.properties.disc_scsi_hot_plug}"
        puts "#{ui.color('Disc Scsi Hot Unplug', :cyan)}: #{snapshot.properties.disc_scsi_hot_unplug}"
      end

      def print_user(user)
        print "\n"
        puts "#{ui.color('ID', :cyan)}: #{user.id}"
        puts "#{ui.color('Firstname', :cyan)}: #{user.properties.firstname}"
        puts "#{ui.color('Lastname', :cyan)}: #{user.properties.lastname}"
        puts "#{ui.color('Email', :cyan)}: #{user.properties.email}"
        puts "#{ui.color('Administrator', :cyan)}: #{user.properties.administrator.to_s}"
        puts "#{ui.color('Force 2-Factor Auth', :cyan)}: #{user.properties.force_sec_auth.to_s}"
        puts "#{ui.color('2-Factor Auth Active', :cyan)}: #{user.properties.sec_auth_active.to_s}"
        puts "#{ui.color('Active', :cyan)}: #{user.properties.active.to_s}"
        puts "#{ui.color('Groups', :cyan)}: #{(user.entities.groups.items.map { |el| el.id }).to_s}" unless user.entities.groups.items.nil?
      end

      def print_volume(volume)
        print "\n"
        puts "#{ui.color('ID', :cyan)}: #{volume.id}"
        puts "#{ui.color('Name', :cyan)}: #{volume.properties.name}"
        puts "#{ui.color('Size', :cyan)}: #{volume.properties.size}"
        puts "#{ui.color('Bus', :cyan)}: #{volume.properties.bus}"
        puts "#{ui.color('Image', :cyan)}: #{volume.properties.image}"
        puts "#{ui.color('Type', :cyan)}: #{volume.properties.type}"
        puts "#{ui.color('Licence Type', :cyan)}: #{volume.properties.licence_type}"
        puts "#{ui.color('Backupunit ID', :cyan)}: #{volume.properties.backupunit_id}"
        puts "#{ui.color('User Data', :cyan)}: #{volume.properties.user_data}"
        puts "#{ui.color('Zone', :cyan)}: #{volume.properties.availability_zone}"
        puts "#{ui.color('CPU Hot Plug', :cyan)}: #{volume.properties.cpu_hot_plug}"
        puts "#{ui.color('RAM Hot Plug', :cyan)}: #{volume.properties.ram_hot_plug}"
        puts "#{ui.color('NIC Hot Plug', :cyan)}: #{volume.properties.nic_hot_plug}"
        puts "#{ui.color('NIC Hot Unplug', :cyan)}: #{volume.properties.nic_hot_unplug}"
        puts "#{ui.color('Disc Virtio Hot Plug', :cyan)}: #{volume.properties.disc_virtio_hot_plug}"
        puts "#{ui.color('Disc Virtio Hot Unplug', :cyan)}: #{volume.properties.disc_virtio_hot_unplug}"
        puts "#{ui.color('Device number', :cyan)}: #{volume.properties.device_number}"
        puts "#{ui.color('PCI Slot', :cyan)}: #{volume.properties.pci_slot}"
      end

      def print_flowlog(flowlog)
        print "\n"
        puts "#{ui.color('ID', :cyan)}: #{flowlog.id}"
        puts "#{ui.color('Name', :cyan)}: #{flowlog.properties.name}"
        puts "#{ui.color('Action', :cyan)}: #{flowlog.properties.action}"
        puts "#{ui.color('Direction', :cyan)}: #{flowlog.properties.direction}"
        puts "#{ui.color('Bucket', :cyan)}: #{flowlog.properties.bucket}"
      end

      def print_network_load_balancer(network_load_balancer)
        print "\n"
        puts "#{ui.color('ID', :cyan)}: #{network_load_balancer.id}"
        puts "#{ui.color('Name', :cyan)}: #{network_load_balancer.properties.name}"
        puts "#{ui.color('Listener LAN', :cyan)}: #{network_load_balancer.properties.listener_lan}"
        puts "#{ui.color('IPS', :cyan)}: #{network_load_balancer.properties.ips}"
        puts "#{ui.color('Target LAN', :cyan)}: #{network_load_balancer.properties.target_lan}"
        puts "#{ui.color('Private IPS', :cyan)}: #{network_load_balancer.properties.lb_private_ips}"
        puts "#{ui.color('Forwarding Rules', :cyan)}: #{network_load_balancer.entities.forwardingrules.items.map do |rule|
          {
            id: rule.id,
            name: rule.properties.name,
            algorithm: rule.properties.algorithm,
            protocol: rule.properties.protocol,
            listener_ip: rule.properties.listener_ip,
            listener_port: rule.properties.listener_port,
            health_check: rule.properties.health_check.nil? ? nil : rule.properties.health_check.to_hash,
            targets: (rule.properties.targets.nil? ? [] : rule.properties.targets.map { |target| target.to_hash }),
          }
        end}"
        puts "#{ui.color('Flowlogs', :cyan)}: #{network_load_balancer.entities.flowlogs.items.map { |flowlog| flowlog.id }}"
      end

      def print_natgateway(natgateway)
        print "\n"
        puts "#{ui.color('ID', :cyan)}: #{natgateway.id}"
        puts "#{ui.color('Name', :cyan)}: #{natgateway.properties.name}"
        puts "#{ui.color('IPS', :cyan)}: #{natgateway.properties.public_ips}"
        puts "#{ui.color('LANS', :cyan)}: #{natgateway.properties.lans.map { |el| { id: el.id, gateway_ips: el.gateway_ips } }}"
        puts "#{ui.color('Rules', :cyan)}: #{natgateway.entities.rules.items.map do |rule|
          {
            id: rule.id,
            name: rule.properties.name,
            type: rule.properties.type,
            protocol: rule.properties.protocol,
            public_ip: rule.properties.public_ip,
            source_subnet: rule.properties.source_subnet,
            target_subnet: rule.properties.target_subnet,
            target_port_range_start: rule.properties.target_port_range ? rule.properties.target_port_range.start : '',
            target_port_range_end: rule.properties.target_port_range ? rule.properties.target_port_range._end : '',
          }
        end}"
        puts "#{ui.color('Flowlogs', :cyan)}: #{natgateway.entities.flowlogs.items.map { |flowlog| flowlog.id }}"
      end

      def print_cluster(cluster)
        connections = cluster.properties.connections.map { |connection| connection.to_hash }
        
        print "\n"
        puts "#{ui.color('ID', :cyan)}: #{cluster.id}"
        puts "#{ui.color('Display Name', :cyan)}: #{cluster.properties.display_name}"
        puts "#{ui.color('Postgres Version', :cyan)}: #{cluster.properties.postgres_version}"
        puts "#{ui.color('Location', :cyan)}: #{cluster.properties.location}"
        puts "#{ui.color('Backup location', :cyan)}: #{cluster.properties.backup_location}"
        puts "#{ui.color('Instances', :cyan)}: #{cluster.properties.instances}"
        puts "#{ui.color('RAM Size', :cyan)}: #{cluster.properties.ram}"
        puts "#{ui.color('Cores', :cyan)}: #{cluster.properties.cores}"
        puts "#{ui.color('Storage Size', :cyan)}: #{cluster.properties.storage_size}"
        puts "#{ui.color('Storage Type', :cyan)}: #{cluster.properties.storage_type}"
        puts "#{ui.color('Connections', :cyan)}: #{connections}"
        puts "#{ui.color('Maintenance Window', :cyan)}: #{cluster.properties.maintenance_window.to_hash}"
        puts "#{ui.color('Synchronization Mode', :cyan)}: #{cluster.properties.synchronization_mode}"
        puts "#{ui.color('Lifecycle Status', :cyan)}: #{cluster.metadata.state}"
      end

      def print_cluster_backup(backup)
        print "\n"
        puts "#{ui.color('ID', :cyan)}: #{backup.id}"
        puts "#{ui.color('Cluster ID', :cyan)}: #{backup.properties.cluster_id}"
        puts "#{ui.color('Version', :cyan)}: #{backup.properties.version}"
        puts "#{ui.color('Is Active', :cyan)}: #{backup.properties.is_active}"
        puts "#{ui.color('Earliest Recovery Target Time', :cyan)}: #{backup.properties.earliest_recovery_target_time}"
        puts "#{ui.color('Created Date', :cyan)}: #{backup.metadata.created_date}"
      end
    end
  end
end

# compact method will remove nil values from Hash
class Hash
  def compact
    delete_if { |_k, v| v.nil? }
  end
end
