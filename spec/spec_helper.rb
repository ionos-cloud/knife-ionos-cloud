$:.unshift File.expand_path('../../lib/chef/knife', __FILE__)
require 'rspec'
require 'chef'
require 'securerandom'
require 'simplecov'

RSpec.configure do |config|
  config.pattern = 'spec/chef/knife/*_spec.rb'
end

SimpleCov.start do
  add_group 'Commands', 'lib/chef/knife/'
  add_group 'Spec files', 'spec/chef/knife/'
end
SimpleCov.coverage_dir 'coverage'

DEFAULT_LOCATION = 'de/fra'

def resource_limits_mock(opts = {})
  Ionoscloud::ResourceLimits.new(
    cores_per_contract: opts[:cores_per_contract] || 8,
    cores_per_server: opts[:cores_per_server] || 4,
    cores_provisioned: opts[:cores_provisioned] || 2,
    hdd_limit_per_contract: opts[:hdd_limit_per_contract] || 600,
    hdd_limit_per_volume: opts[:hdd_limit_per_volume] || 400,
    hdd_volume_provisioned: opts[:hdd_volume_provisioned] || 100,
    ram_per_contract: opts[:ram_per_contract] || 20480,
    ram_per_server: opts[:ram_per_server] || 20480,
    ram_provisioned: opts[:ram_provisioned] || 4096,
    reservable_ips: opts[:reservable_ips] || 10,
    reserved_ips_in_use: opts[:reserved_ips_in_use] || 12,
    reserved_ips_on_contract: opts[:reserved_ips_on_contract] || 20,
    ssd_limit_per_contract: opts[:ssd_limit_per_contract] || 600,
    ssd_limit_per_volume: opts[:ssd_limit_per_volume] || 300,
    ssd_volume_provisioned: opts[:ssd_volume_provisioned] || 50,
    k8s_cluster_limit_total: opts[:k8s_cluster_limit_total] || 12,
    k8s_clusters_provisioned: opts[:k8s_clusters_provisioned] || 1,
  )
end

def contract_mock(opts = {})
  Ionoscloud::Contract.new(
    type: opts[:type] || 'contract',
    properties: Ionoscloud::ContractProperties.new(
      contract_number: opts[:contract_number] || 31884391,
      owner: opts[:owner] || 'user@domain.com',
      reg_domain: opts[:reg_domain] || 'ionos.de',
      status: opts[:status] || 'BILLABLE',
      resource_limits: opts[:resource_limits] || resource_limits_mock(opts),
    ),
  )
end

def ipblock_mock(opts = {})
  Ionoscloud::IpBlock.new(
    id: opts[:id] || SecureRandom.uuid,
    properties: Ionoscloud::IpBlockProperties.new(
      name: opts[:name] || 'Test IpBlock',
      size: opts[:size] || 4,
      location: opts[:location] || DEFAULT_LOCATION,
      ips: opts[:ips] || ['127.106.113.181', '127.106.113.176', '127.106.113.177', '127.106.113.178'],
    ),
  )
end

def ipblocks_mock(opts = {})
  Ionoscloud::IpBlocks.new(
    id: 'IpBlocks',
    type: 'collection',
    items: [ipblock_mock, ipblock_mock],
  )
end

def datacenter_mock(opts = {})
  Ionoscloud::Datacenter.new(
    id: opts[:id] || SecureRandom.uuid,
    properties: Ionoscloud::DatacenterProperties.new(
      name: opts[:name] || 'Test Datacenter',
      description: opts[:description] || 'Test description',
      location: opts[:location] || DEFAULT_LOCATION,
      version: opts[:version] || 12,
    ),
  )
end

def datacenters_mock(opts = {})
  Ionoscloud::Datacenters.new(
    id: 'Datacenters',
    type: 'collection',
    items: [datacenter_mock, datacenter_mock],
  )
end

def server_mock(opts = {})
  Ionoscloud::Server.new(
    id: opts[:id] || SecureRandom.uuid,
    properties: Ionoscloud::ServerProperties.new(
      name: opts[:name] || 'Test Server',
      ram: opts[:ram] || 1024,
      cores: opts[:cores] || 1,
      availability_zone: opts[:availability_zone] || 'ZONE_1',
      cpu_family: opts[:cpu_family] || 'INTEL_SKYLAKE',
      boot_cdrom: opts[:boot_cdrom] || Ionoscloud::ResourceReference.new({ id: SecureRandom.uuid }),
      boot_volume: opts[:boot_volume] || Ionoscloud::ResourceReference.new({ id: SecureRandom.uuid }),
    ),
    entities: Ionoscloud::ServerEntities.new(
      volumes: opts[:volumes] || [],
      nics: opts[:nics] || [],
    )
  )
end

def servers_mock(opts = {})
  Ionoscloud::Servers.new(
    id: 'servers',
    type: 'collection',
    items: [server_mock, server_mock],
  )
end

def volume_mock(opts = {})
  Ionoscloud::Volume.new(
    id: opts[:id] || SecureRandom.uuid,
    properties: Ionoscloud::VolumeProperties.new(
      name: opts[:name] || 'Test Volume',
      size: opts[:size] || 2,
      type: opts[:type] || 'HDD',
      bus: opts[:bus] || 'VIRTIO',
      availability_zone: opts[:availability_zone] || 'AUTO',
      licence_type: opts[:licence_type] || 'LINUX',
      image: opts[:image] || SecureRandom.uuid,
    ),
  )
end

def volumes_mock(opts = {})
  Ionoscloud::Volumes.new(
    id: 'volumes',
    type: 'collection',
    items: [volume_mock, volume_mock],
  )
end

def label_resource_mock(opts = {})
  Ionoscloud::LabelResource.new(
    id: opts[:id] || SecureRandom.uuid,
    properties: Ionoscloud::LabelResourceProperties.new(
      key: opts[:key] || 'key',
      value: opts[:value] || 'value',
    ),
  )
end

def label_resources_mock(opts = {})
  Ionoscloud::LabelResources.new(
    id: 'labelresources',
    type: 'collection',
    items: [label_resource_mock, label_resource_mock],
  )
end

def label_mock(opts = {})
  Ionoscloud::Label.new(
    id: opts[:id] || SecureRandom.uuid,
    properties: Ionoscloud::LabelProperties.new(
      resource_id: opts[:resource_id] || 'resource_id',
      resource_type: opts[:resource_type] || 'resource_type',
      key: opts[:key] || 'key',
      value: opts[:value] || 'value',
    ),
  )
end

def labels_mock(opts = {})
  Ionoscloud::Labels.new(
    id: 'labels',
    type: 'collection',
    items: [label_mock, label_mock],
  )
end

def backupunit_mock(opts = {})
  Ionoscloud::BackupUnit.new(
    id: opts[:id] || SecureRandom.uuid,
    properties: Ionoscloud::BackupUnitProperties.new(
      name: opts[:name] || 'backupunit_name',
      password: opts[:password] || 'password1234',
      email: opts[:email] || 'test@test.com',
    ),
  )
end

def backupunits_mock(opts = {})
  Ionoscloud::BackupUnits.new(
    id: 'backupunits',
    type: 'collection',
    items: [backupunit_mock, backupunit_mock],
  )
end

def lan_mock(opts = {})
  Ionoscloud::Lan.new(
    id: opts[:id] || '1',
    properties: Ionoscloud::LanProperties.new(
      name: opts[:name] || 'lan_name',
      public: opts[:public] || true,
      pcc: opts[:pcc] || SecureRandom.uuid,
      ip_failover: opts[:ip_failover] || [],
    ),
  )
end

def lans_mock(opts = {})
  Ionoscloud::Lans.new(
    id: 'lans',
    type: 'collection',
    items: [lan_mock],
  )
end

def nic_mock(opts = {})
  Ionoscloud::Nic.new(
    id: opts[:id] || SecureRandom.uuid,
    properties: Ionoscloud::NicProperties.new(
      name: opts[:name] || 'nic_name',
      ips: opts[:ips] || ['127.1.1.1', '127.1.1.2'],
      nat: opts[:nat] || true,
      dhcp: opts[:dhcp] || true,
      firewall_active: opts[:firewall_active] || true,
      mac: opts[:mac] || '00:0a:95:9d:68:16',
      lan: opts[:lan] || 1,
    ),
    entities: Ionoscloud::NicEntities.new(
      firewallrules: opts[:firewallrules] || [],
    )
  )
end

def nics_mock(opts = {})
  Ionoscloud::Nics.new(
    id: 'nics',
    type: 'collection',
    items: [nic_mock, nic_mock],
  )
end

def firewall_mock(opts = {})
  Ionoscloud::FirewallRule.new(
    id: opts[:id] || SecureRandom.uuid,
    properties: Ionoscloud::FirewallruleProperties.new(
      name: opts[:name] || 'firewall_name',
      protocol: opts[:protocol] || 'UDP',
      source_mac: opts[:source_mac] || '01:23:45:67:89:00',
      source_ip: opts[:source_ip] || '127.9.20.11',
      target_ip: opts[:target_ip] || '127.9.20.11',
      port_range_start: opts[:port_range_start] || 22,
      port_range_end: opts[:port_range_end] || 22,
      icmp_type: opts[:icmp_type] || 4,
      icmp_code: opts[:icmp_code] || 7,
    ),
  )
end

def firewalls_mock(opts = {})
  Ionoscloud::FirewallRules.new(
    id: 'firewalls',
    type: 'collection',
    items: [firewall_mock, firewall_mock],
  )
end

def load_balancer_mock(opts = {})
  Ionoscloud::Loadbalancer.new(
    id: opts[:id] || SecureRandom.uuid,
    properties: Ionoscloud::LoadbalancerProperties.new(
      name: opts[:name] || 'load_balancer_name',
      ip: opts[:ip] || '127.1.1.1',
      dhcp: opts[:dhcp] || true,
    ),
    entities: Ionoscloud::LoadbalancerEntities.new(
      balancednics: opts[:nics] || nics_mock,
    )
  )
end

def load_balancers_mock(opts = {})
  Ionoscloud::Loadbalancers.new(
    id: 'loadbalancers',
    type: 'collection',
    items: [load_balancer_mock],
  )
end

def image_mock(opts = {})
  Ionoscloud::Image.new(
    id: opts[:id] || SecureRandom.uuid,
    properties: Ionoscloud::ImageProperties.new(
      name: opts[:name] || 'image_name',
      image_aliases: opts[:image_aliases] || ['alias1', 'alias2'],
      location: opts[:location] || 'image_location',
      size: opts[:size] || 10,
      public: opts[:public] || true,
    ),
  )
end

def images_mock(opts = {})
  Ionoscloud::Images.new(
    id: 'images',
    type: 'collection',
    items: [image_mock],
  )
end

def location_mock(opts = {})
  Ionoscloud::Location.new(
    id: opts[:id] || SecureRandom.uuid,
    properties: Ionoscloud::LocationProperties.new(
      name: opts[:name] || 'location_name',
    ),
  )
end

def locations_mock(opts = {})
  Ionoscloud::Locations.new(
    id: 'locations',
    type: 'collection',
    items: [location_mock],
  )
end

def location_mock(opts = {})
  Ionoscloud::Location.new(
    id: opts[:id] || SecureRandom.uuid,
    properties: Ionoscloud::LocationProperties.new(
      name: opts[:name] || 'location_name',
    ),
  )
end

def locations_mock(opts = {})
  Ionoscloud::Locations.new(
    id: 'locations',
    type: 'collection',
    items: [location_mock],
  )
end

def maintenance_window_mock(opts = {})
  Ionoscloud::KubernetesMaintenanceWindow.new(
    day_of_the_week: opts[:day_of_the_week] || 'Sunday',
    time: opts[:time] || '23:03:19Z',
  )
end

def auto_scaling_mock(opts = {})
  Ionoscloud::KubernetesAutoScaling.new(
    min_node_count: opts[:min_node_count] || 2,
    max_node_count: opts[:max_node_count] || 3,
  )
end

def kubeconfig_mock(opts = {})
  Ionoscloud::KubernetesConfig.new(
    id: opts[:id] || SecureRandom.uuid,
    properties: Ionoscloud::KubernetesConfigProperties.new(
      kubeconfig: opts[:kubeconfig] || 'kubeconfig_file_data',
    ),
  )
end

def k8s_cluster_mock(opts = {})
  Ionoscloud::KubernetesCluster.new(
    id: opts[:id] || SecureRandom.uuid,
    properties: Ionoscloud::KubernetesClusterProperties.new(
      name: opts[:name] || 'k8s_cluster_name',
      k8s_version: opts[:k8s_version] || '1.15.4,',
      maintenance_window: opts[:maintenance_window] || maintenance_window_mock,
      api_subnet_allow_list: opts[:api_subnet_allow_list] || [
        "127.2.3.4/32",
        "2002::1234:abcd:ffff:c0a8:101/64",
        "127.2.3.4",
      ],
      s3_buckets: opts[:s3_buckets] || [
        Ionoscloud::S3Bucket.new(name: 'test_name1'),
        Ionoscloud::S3Bucket.new(name: 'test_name2'),
      ],
      available_upgrade_versions: opts[:available_upgrade_versions] || ['1.16.4', '1.17.7'],
      viable_node_pool_versions: opts[:viable_node_pool_versions] || ['1.17.8', '1.18.2']
    ),
    metadata: Ionoscloud::DatacenterElementMetadata.new(
      state: opts[:state] || 'ACTIVE',
    ),
    entities: opts[:entities] || Ionoscloud::KubernetesClusterEntities.new(
      nodepools: k8s_nodepools_mock,
    ),
  )
end

def k8s_clusters_mock(opts = {})
  Ionoscloud::KubernetesClusters.new(
    id: 'k8s',
    type: 'collection',
    items: [k8s_cluster_mock],
  )
end

def k8s_nodepool_properties_mock(opts = {})
  Ionoscloud::KubernetesNodePoolProperties.new(
    name: opts[:name] || 'k8s_nodepool_name',
    datacenter_id: opts[:datacenter_id] || SecureRandom.uuid,
    node_count: opts[:node_count] || 2,
    cores_count: opts[:cores_count] || 2,
    cpu_family: opts[:cpu_family] || 'AMD_OPTERON',
    ram_size: opts[:ram_size] || 2048,
    availability_zone: opts[:availability_zone] || 'AUTO',
    storage_type: opts[:storage_type] || 'SSD',
    storage_size: opts[:storage_size] || 100,
    k8s_version: opts[:k8s_version] || '1.15.4',
    maintenance_window: opts[:maintenance_window] || maintenance_window_mock,
    auto_scaling: opts[:auto_scaling] || auto_scaling_mock,
    lans: opts[:lans] || [lan_mock, lan_mock],
    labels: opts[:labels] || { "test_labels": "test_labels" },
    annotations: opts[:annotations] || { "test_annotations": "test_annotations" },
    public_ips: opts[:public_ips] || ['127.173.1.2', '127.231.2.5', '127.221.2.4'],
    available_upgrade_versions: opts[:available_upgrade_versions] || ['1.16.4', '1.17.7'],
  )
end

def k8s_nodepool_mock(opts = {})
  Ionoscloud::KubernetesNodePool.new(
    id: opts[:id] || SecureRandom.uuid,
    properties: k8s_nodepool_properties_mock(opts),
    metadata: Ionoscloud::KubernetesNodeMetadata.new(
      state: 'READY',
    ),
  )
end

def k8s_nodepools_mock(opts = {})
  Ionoscloud::KubernetesNodePools.new(
    id: "#{SecureRandom.uuid}/nodepools",
    type: 'collection',
    items: opts[:items] || [k8s_nodepool_mock],
  )
end

def k8s_node_mock(opts = {})
  Ionoscloud::KubernetesNode.new(
    id: opts[:id] || SecureRandom.uuid,
    properties: Ionoscloud::KubernetesNodeProperties.new(
      name: opts[:name] || 'k8s_node_name',
      k8s_version: opts[:k8s_version] || '1.17.10',
      public_ip: opts[:public_ip] || '127.1.1.1',
    ),
    metadata: Ionoscloud::KubernetesNodeMetadata.new(
      state: 'READY',
    ),
  )
end

def k8s_nodes_mock(opts = {})
  Ionoscloud::KubernetesNodes.new(
    id: "#{SecureRandom.uuid}/nodes",
    type: 'collection',
    items: [k8s_node_mock],
  )
end

def datacenter_mock(opts = {})
  Ionoscloud::Datacenter.new(
    id: opts[:id] || SecureRandom.uuid,
    properties: Ionoscloud::DatacenterProperties.new(
      name: opts[:name] || 'datacenter_name',
      description: opts[:description] || 'datacenter_description',
      location: opts[:location] || DEFAULT_LOCATION,
    ),
  )
end

def datacenters_mock(opts = {})
  Ionoscloud::Datacenters.new(
    id: 'datacenters',
    type: 'collection',
    items: [datacenter_mock],
  )
end

def pcc_mock(opts = {})
  Ionoscloud::PrivateCrossConnect.new(
    id: opts[:id] || SecureRandom.uuid,
    properties: Ionoscloud::PrivateCrossConnectProperties.new(
      name: opts[:name] || 'pcc_name',
      description: opts[:description] || 'pcc_description',
      peers: opts[:peers] || [lan_mock, lan_mock],
      connectable_datacenters: opts[:connectable_datacenters] || [datacenter_mock, datacenter_mock],
    ),
  )
end

def pccs_mock(opts = {})
  Ionoscloud::PrivateCrossConnects.new(
    id: 'pccs',
    type: 'collection',
    items: [pcc_mock],
  )
end

def backupunit_sso_mock(opts = {})
  Ionoscloud::BackupUnitSSO.new(
    sso_url: opts['sso_url'] || 'www.sso-url.com',
  )
end

def sso_url_mock(opts = {})
  Ionoscloud::S3ObjectStorageSSO.new(
    sso_url: opts['sso_url'] || 'www.sso-url.com',
  )
end

def s3_key_mock(opts = {})
  Ionoscloud::S3Key.new(
    id: opts[:id] || SecureRandom.uuid,
    properties: Ionoscloud::S3KeyProperties.new(
      secret_key: opts[:secret_key] || 'secret_key',
      active: opts[:active] || true,
    ),
  )
end

def s3_keys_mock(opts = {})
  Ionoscloud::S3Keys.new(
    id: 's3keys',
    type: 'collection',
    items: [s3_key_mock],
  )
end

def group_share_mock(opts = {})
  Ionoscloud::GroupShare.new(
    id: opts[:id] || SecureRandom.uuid,
    properties: Ionoscloud::GroupShareProperties.new(
      edit_privilege: opts[:edit_privilege] || true,
      share_privilege: opts[:share_privilege] || true,
    ),
  )
end

def group_shares_mock(opts = {})
  Ionoscloud::GroupShares.new(
    id: 'shares',
    type: 'collection',
    items: [group_share_mock],
  )
end

def resource_mock(opts = {})
  Ionoscloud::Resource.new(
    id: opts[:id] || SecureRandom.uuid,
    type: opts[:type] || 'resource_type',
    properties: Ionoscloud::ResourceProperties.new(
      name: opts[:name] || 'resource_name',
    ),
  )
end

def resources_mock(opts = {})
  Ionoscloud::Resources.new(
    id: 'resources',
    type: 'collection',
    items: [resource_mock],
  )
end

def snapshot_mock(opts = {})
  Ionoscloud::Snapshot.new(
    id: opts[:id] || SecureRandom.uuid,
    properties: Ionoscloud::SnapshotProperties.new(
      name: opts[:name] || 'snapshot_name',
      description: opts[:description] || 'snapshot_description',
      licence_type: opts[:licence_type] || 'LINUX',
      sec_auth_protection: opts[:sec_auth_protection] || true,
      location: opts[:location] || DEFAULT_LOCATION,
      size: opts[:size] || 10.0,

      cpu_hot_plug: opts[:cpu_hot_plug] || true,
      cpu_hot_unplug: opts[:cpu_hot_unplug] || true,
      ram_hot_plug: opts[:ram_hot_plug] || false,
      ram_hot_unplug: opts[:ram_hot_unplug] || true,
      nic_hot_plug: opts[:nic_hot_plug] || true,
      nic_hot_unplug: opts[:nic_hot_unplug] || false,
      disc_virtio_hot_plug: opts[:disc_virtio_hot_plug] || false,
      disc_virtio_hot_unplug: opts[:disc_virtio_hot_unplug] || false,
      disc_scsi_hot_plug: opts[:disc_scsi_hot_plug] || true,
      disc_scsi_hot_unplug: opts[:disc_scsi_hot_unplug] || true,

    ),
  )
end

def snapshots_mock(opts = {})
  Ionoscloud::Snapshots.new(
    id: 'snapshots',
    type: 'collection',
    items: [snapshot_mock],
  )
end

def group_mock(opts = {})
  Ionoscloud::Group.new(
    id: opts[:id] || SecureRandom.uuid,
    properties: Ionoscloud::GroupProperties.new(
      name: opts[:name] || 'group_name',
      create_data_center: opts[:create_data_center] || true,
      create_snapshot: opts[:create_snapshot] || true,
      reserve_ip: opts[:reserve_ip] || true,
      access_activity_log: opts[:access_activity_log] || true,
      s3_privilege: opts[:s3_privilege] || true,
      create_backup_unit: opts[:create_backup_unit] || true,
      create_k8s_cluster: opts[:create_k8s_cluster] || true,
      create_pcc: opts[:create_pcc] || true,
      create_internet_access: opts[:create_internet_access] || true,
    ),
    entities: Ionoscloud::GroupEntities.new(
      users: group_members_mock,
    ),
  )
end

def groups_mock(opts = {})
  Ionoscloud::Groups.new(
    id: 'groups',
    type: 'collection',
    items: [group_mock, group_mock],
  )
end

def group_members_mock(opts = {})
  Ionoscloud::GroupMembers.new(
    id: 'groupmembers',
    type: 'collection',
    items: [user_mock, user_mock],
  )
end

def user_mock(opts = {})
  Ionoscloud::User.new(
    id: opts[:id] || SecureRandom.uuid,
    properties: Ionoscloud::UserPropertiesPost.new(
      firstname: opts[:firstname] || 'Firstname',
      lastname: opts[:lastname] || 'Lastname',
      email: opts[:email] || 'a@a.a',
      password: opts[:password] || 'parola1234',
      administrator: opts[:administrator] || false,
      force_sec_auth: opts[:force_sec_auth] || false,
    ),
    entities: Ionoscloud::UsersEntities.new(
      groups: Ionoscloud::Groups.new(
        items: opts[:groups] || []
      )
    )
  )
end

def users_mock(opts = {})
  Ionoscloud::Users.new(
    id: 'users',
    type: 'collection',
    items: [user_mock],
  )
end

def request_status_mock(opts = {})
  Ionoscloud::RequestStatus.new(
    id: opts[:id] || SecureRandom.uuid,
    metadata: Ionoscloud::RequestStatusMetadata.new(
      status: opts[:status] || 'DONE',
      message: opts[:message] || 'Message',
      targets: opts[:targets] || []
    ),
  )
end

def request_target_mock(opts = {})
  Ionoscloud::RequestTarget.new(
    status: opts[:status] || 'DONE',
    target: opts[:target] || resource_mock,
  )
end

def request_mock(opts = {})
  Ionoscloud::Request.new(
    id: opts[:id] || SecureRandom.uuid,
    properties: Ionoscloud::RequestProperties.new(
      method: opts[:method] || 'POST',
      url: opts[:url] || 'www.url.com',
      body: opts[:body] || { 'test' => 'test'},
      headers: opts[:headers] || { 'test2' => 'test2'},
    ),
    metadata: Ionoscloud::RequestMetadata.new(
      request_status: request_status_mock(opts)
    )
  )
end

def requests_mock(opts = {})
  Ionoscloud::Requests.new(
    id: 'requests',
    type: 'collection',
    items: [request_mock, request_mock({ targets: [request_target_mock] })],
  )
end

def check_backupunit_print(subject, backupunit)
  expect(subject).to receive(:puts).with("ID: #{backupunit.id}")
  expect(subject).to receive(:puts).with("Name: #{backupunit.properties.name}")
  expect(subject).to receive(:puts).with("Email: #{backupunit.properties.email}")
end

def check_datacenter_print(subject, datacenter)
  expect(subject).to receive(:puts).with("ID: #{datacenter.id}")
  expect(subject).to receive(:puts).with("Name: #{datacenter.properties.name}")
  expect(subject).to receive(:puts).with("Description: #{datacenter.properties.description}")
  expect(subject).to receive(:puts).with("Location: #{datacenter.properties.location}")
  expect(subject).to receive(:puts).with("Version: #{datacenter.properties.version}")
  expect(subject).to receive(:puts).with("Features: #{datacenter.properties.features}")
  expect(subject).to receive(:puts).with("Sec Auth Protection: #{datacenter.properties.sec_auth_protection}")
end

def check_firewall_print(subject, firewall)
  expect(subject).to receive(:puts).with("ID: #{firewall.id}")
  expect(subject).to receive(:puts).with("Name: #{firewall.properties.name}")
  expect(subject).to receive(:puts).with("Protocol: #{firewall.properties.protocol}")
  expect(subject).to receive(:puts).with("Source MAC: #{firewall.properties.source_mac}")
  expect(subject).to receive(:puts).with("Source IP: #{firewall.properties.source_ip}")
  expect(subject).to receive(:puts).with("Target IP: #{firewall.properties.target_ip}")
  expect(subject).to receive(:puts).with("Port Range Start: #{firewall.properties.port_range_start}")
  expect(subject).to receive(:puts).with("Port Range End: #{firewall.properties.port_range_end}")
  expect(subject).to receive(:puts).with("ICMP Type: #{firewall.properties.icmp_type}")
  expect(subject).to receive(:puts).with("ICMP Code: #{firewall.properties.icmp_code}")
end

def check_group_print(subject, group)
  users = group.entities.users.items.map { |el| el.id }

  expect(subject).to receive(:puts).with("ID: #{group.id}")
  expect(subject).to receive(:puts).with("Name: #{group.properties.name}")
  expect(subject).to receive(:puts).with("Create Datacenter: #{group.properties.create_data_center.to_s}")
  expect(subject).to receive(:puts).with("Create Snapshot: #{group.properties.create_snapshot.to_s}")
  expect(subject).to receive(:puts).with("Reserve IP: #{group.properties.reserve_ip.to_s}")
  expect(subject).to receive(:puts).with("Access Activity Log: #{group.properties.access_activity_log.to_s}")
  expect(subject).to receive(:puts).with("S3 Privilege: #{group.properties.s3_privilege.to_s}")
  expect(subject).to receive(:puts).with("Create Backup Unit: #{group.properties.create_backup_unit.to_s}")
  expect(subject).to receive(:puts).with("Create K8s Clusters: #{group.properties.create_k8s_cluster.to_s}")
  expect(subject).to receive(:puts).with("Create PCC: #{group.properties.create_pcc.to_s}")
  expect(subject).to receive(:puts).with("Create Internet Acess: #{group.properties.create_internet_access.to_s}")
  expect(subject).to receive(:puts).with("Users: #{users.to_s}")
end

def check_ipblock_print(subject, ipblock)
  ip_consumers = (ipblock.properties.ip_consumers.nil? ? [] : ipblock.properties.ip_consumers.map { |el| el.to_hash })
  expect(subject).to receive(:puts).with("ID: #{ipblock.id}")
  expect(subject).to receive(:puts).with("Name: #{ipblock.properties.name}")
  expect(subject).to receive(:puts).with("IP Addresses: #{ipblock.properties.ips.to_s}")
  expect(subject).to receive(:puts).with("Location: #{ipblock.properties.location}")
  expect(subject).to receive(:puts).with("IP Consumers: #{ip_consumers}")
end

def check_lan_print(subject, lan)
  ip_failovers = (lan.properties.ip_failover.nil? ? [] : lan.properties.ip_failover.map { |el| el.to_hash })
  expect(subject).to receive(:puts).with("ID: #{lan.id}")
  expect(subject).to receive(:puts).with("Name: #{lan.properties.name}")
  expect(subject).to receive(:puts).with("Public: #{lan.properties.public.to_s}")
  expect(subject).to receive(:puts).with("PCC: #{lan.properties.pcc}")
  expect(subject).to receive(:puts).with("IP Failover: #{ip_failovers}")
end

def check_k8s_cluster_print(subject, cluster)
  maintenance_window = "#{cluster.properties.maintenance_window.day_of_the_week}, #{cluster.properties.maintenance_window.time}"
  s3_buckets = (cluster.properties.s3_buckets.nil? ? [] : cluster.properties.s3_buckets.map { |el| el.name })

  expect(subject).to receive(:puts).with("ID: #{cluster.id}")
  expect(subject).to receive(:puts).with("Name: #{cluster.properties.name}")
  expect(subject).to receive(:puts).with("Public: #{cluster.properties.public}")
  expect(subject).to receive(:puts).with("k8s Version: #{cluster.properties.k8s_version}")
  expect(subject).to receive(:puts).with("Maintenance Window: #{maintenance_window}")
  expect(subject).to receive(:puts).with("State: #{cluster.metadata.state}")
  expect(subject).to receive(:puts).with("Api Subnet Allow List: #{cluster.properties.api_subnet_allow_list}")
  expect(subject).to receive(:puts).with("S3 Buckets: #{s3_buckets}")
  expect(subject).to receive(:puts).with("Available Upgrade Versions: #{cluster.properties.available_upgrade_versions}")
  expect(subject).to receive(:puts).with("Viable NodePool Versions: #{cluster.properties.viable_node_pool_versions}")
end

def check_loadbalancer_print(subject, load_balancer)
  nics = load_balancer.entities.balancednics.items.map { |nic| nic.id }

  expect(subject).to receive(:puts).with("ID: #{load_balancer.id}")
  expect(subject).to receive(:puts).with("Name: #{load_balancer.properties.name}")
  expect(subject).to receive(:puts).with("IP address: #{load_balancer.properties.ip}")
  expect(subject).to receive(:puts).with("DHCP: #{load_balancer.properties.dhcp}")
  expect(subject).to receive(:puts).with("Balanced Nics: #{nics.to_s}")
end

def check_nic_print(subject, nic)
  expect(subject).to receive(:puts).with("ID: #{nic.id}")
  expect(subject).to receive(:puts).with("Name: #{nic.properties.name}")
  expect(subject).to receive(:puts).with("IPs: #{nic.properties.ips.to_s}")
  expect(subject).to receive(:puts).with("DHCP: #{nic.properties.dhcp}")
  expect(subject).to receive(:puts).with("LAN: #{nic.properties.lan}")
  expect(subject).to receive(:puts).with("NAT: #{nic.properties.nat}")
end

def check_k8s_node_print(subject, k8s_node)
  expect(subject).to receive(:puts).with("ID: #{k8s_node.id}")
  expect(subject).to receive(:puts).with("Name: #{k8s_node.properties.name}")
  expect(subject).to receive(:puts).with("Public IP: #{k8s_node.properties.public_ip}")
  expect(subject).to receive(:puts).with("Private IP: #{k8s_node.properties.private_ip}")
  expect(subject).to receive(:puts).with("K8s Version: #{k8s_node.properties.k8s_version}")
  expect(subject).to receive(:puts).with("State: #{k8s_node.metadata.state}")
end

def check_k8s_nodepool_print(subject, nodepool)
  auto_scaling = "Min node count: #{nodepool.properties.auto_scaling.min_node_count}, Max node count:#{nodepool.properties.auto_scaling.max_node_count}"
  maintenance_window = "#{nodepool.properties.maintenance_window.day_of_the_week}, #{nodepool.properties.maintenance_window.time}"
  lans = nodepool.properties.lans.map { |lan| { id: lan.id } }

  expect(subject).to receive(:puts).with("ID: #{nodepool.id}")
  expect(subject).to receive(:puts).with("Name: #{nodepool.properties.name}")
  expect(subject).to receive(:puts).with("K8s Version: #{nodepool.properties.k8s_version}")
  expect(subject).to receive(:puts).with("Datacenter ID: #{nodepool.properties.datacenter_id}")
  expect(subject).to receive(:puts).with("Node Count: #{nodepool.properties.node_count}")
  expect(subject).to receive(:puts).with("CPU Family: #{nodepool.properties.cpu_family}")
  expect(subject).to receive(:puts).with("Cores Count: #{nodepool.properties.cores_count}")
  expect(subject).to receive(:puts).with("RAM: #{nodepool.properties.ram_size}")
  expect(subject).to receive(:puts).with("Storage Type: #{nodepool.properties.storage_type}")
  expect(subject).to receive(:puts).with("Storage Size: #{nodepool.properties.storage_size}")
  expect(subject).to receive(:puts).with("Public IPs: #{nodepool.properties.public_ips}")
  expect(subject).to receive(:puts).with("Labels: #{nodepool.properties.labels}")
  expect(subject).to receive(:puts).with("Annotations: #{nodepool.properties.annotations}")
  expect(subject).to receive(:puts).with("LANs: #{lans}")
  expect(subject).to receive(:puts).with("Availability Zone: #{nodepool.properties.availability_zone}")
  expect(subject).to receive(:puts).with("Auto Scaling: #{auto_scaling}")
  expect(subject).to receive(:puts).with("Maintenance Window: #{maintenance_window}")
  expect(subject).to receive(:puts).with("State: #{nodepool.metadata.state}")
end

def check_pcc_print(subject, pcc)
  peers = pcc.properties.peers.map { |peer| peer.id }
  datacenters = pcc.properties.connectable_datacenters.map { |datacenter| datacenter.id }

  expect(subject).to receive(:puts).with("ID: #{pcc.id}")
  expect(subject).to receive(:puts).with("Name: #{pcc.properties.name}")
  expect(subject).to receive(:puts).with("Description: #{pcc.properties.description}")
  expect(subject).to receive(:puts).with("Peers: #{peers.to_s}")
  expect(subject).to receive(:puts).with("Connectable Datacenters: #{datacenters.to_s}")
end

def check_s3key_print(subject, s3_key)
  expect(subject).to receive(:puts).with("ID: #{s3_key.id}")
  expect(subject).to receive(:puts).with("Secret Key: #{s3_key.properties.secret_key}")
  expect(subject).to receive(:puts).with("Active: #{s3_key.properties.active}")
end

def check_server_print(subject, server)
  expect(subject).to receive(:puts).with("ID: #{server.id}")
  expect(subject).to receive(:puts).with("Name: #{server.properties.name}")
  expect(subject).to receive(:puts).with("Cores: #{server.properties.cores}")
  expect(subject).to receive(:puts).with("CPU Family: #{server.properties.cpu_family}")
  expect(subject).to receive(:puts).with("Ram: #{server.properties.ram}")
  expect(subject).to receive(:puts).with("Availability Zone: #{server.properties.availability_zone}")
  expect(subject).to receive(:puts).with("Boot Volume: #{server.properties.boot_volume.id}")
  expect(subject).to receive(:puts).with("Boot CDROM: #{server.properties.boot_cdrom.id}")
end

def check_share_print(subject, share)
  expect(subject).to receive(:puts).with("ID: #{share.id}")
  expect(subject).to receive(:puts).with("Edit Privilege: #{share.properties.edit_privilege.to_s}")
  expect(subject).to receive(:puts).with("Share Privilege: #{share.properties.share_privilege.to_s}")
end

def check_snapshot_print(subject, snapshot)
  expect(subject).to receive(:puts).with("ID: #{snapshot.id}")
  expect(subject).to receive(:puts).with("Name: #{snapshot.properties.name}")
  expect(subject).to receive(:puts).with("Description: #{snapshot.properties.description}")
  expect(subject).to receive(:puts).with("Location: #{snapshot.properties.location}")
  expect(subject).to receive(:puts).with("Size: #{snapshot.properties.size.to_s}")
  expect(subject).to receive(:puts).with("Sec Auth Protection: #{snapshot.properties.sec_auth_protection}")
  expect(subject).to receive(:puts).with("License Type: #{snapshot.properties.licence_type}")
  expect(subject).to receive(:puts).with("CPU Hot Plug: #{snapshot.properties.cpu_hot_plug}")
  expect(subject).to receive(:puts).with("CPU Hot Unplug: #{snapshot.properties.cpu_hot_unplug}")
  expect(subject).to receive(:puts).with("RAM Hot Plug: #{snapshot.properties.ram_hot_plug}")
  expect(subject).to receive(:puts).with("RAM Hot Unplug: #{snapshot.properties.ram_hot_unplug}")
  expect(subject).to receive(:puts).with("NIC Hot Plug: #{snapshot.properties.nic_hot_plug}")
  expect(subject).to receive(:puts).with("NIC Hot Unplug: #{snapshot.properties.nic_hot_unplug}")
  expect(subject).to receive(:puts).with("Disc Virtio Hot Plug: #{snapshot.properties.disc_virtio_hot_plug}")
  expect(subject).to receive(:puts).with("Disc Virtio Hot Unplug: #{snapshot.properties.disc_virtio_hot_unplug}")
  expect(subject).to receive(:puts).with("Disc Scsi Hot Plug: #{snapshot.properties.disc_scsi_hot_plug}")
  expect(subject).to receive(:puts).with("Disc Scsi Hot Unplug: #{snapshot.properties.disc_scsi_hot_unplug}")
end

def check_volume_print(subject, volume)
  expect(subject).to receive(:puts).with("ID: #{volume.id}")
  expect(subject).to receive(:puts).with("Name: #{volume.properties.name}")
  expect(subject).to receive(:puts).with("Size: #{volume.properties.size}")
  expect(subject).to receive(:puts).with("Bus: #{volume.properties.bus}")
  expect(subject).to receive(:puts).with("Image: #{volume.properties.image}")
  expect(subject).to receive(:puts).with("Type: #{volume.properties.type}")
  expect(subject).to receive(:puts).with("Licence Type: #{volume.properties.licence_type}")
  expect(subject).to receive(:puts).with("Backupunit ID: #{volume.properties.backupunit_id}")
  expect(subject).to receive(:puts).with("User Data: #{volume.properties.user_data}")
  expect(subject).to receive(:puts).with("Zone: #{volume.properties.availability_zone}")
  expect(subject).to receive(:puts).with("CPU Hot Plug: #{volume.properties.cpu_hot_plug}")
  expect(subject).to receive(:puts).with("RAM Hot Plug: #{volume.properties.ram_hot_plug}")
  expect(subject).to receive(:puts).with("NIC Hot Plug: #{volume.properties.nic_hot_plug}")
  expect(subject).to receive(:puts).with("NIC Hot Unplug: #{volume.properties.nic_hot_unplug}")
  expect(subject).to receive(:puts).with("Disc Virtio Hot Plug: #{volume.properties.disc_virtio_hot_plug}")
  expect(subject).to receive(:puts).with("Disc Virtio Hot Unplug: #{volume.properties.disc_virtio_hot_unplug}")
  expect(subject).to receive(:puts).with("Device number: #{volume.properties.device_number}")
end

def check_user_print(subject, user)
  expect(subject).to receive(:puts).with("ID: #{user.id}")
  expect(subject).to receive(:puts).with("Firstname: #{user.properties.firstname}")
  expect(subject).to receive(:puts).with("Lastname: #{user.properties.lastname}")
  expect(subject).to receive(:puts).with("Email: #{user.properties.email}")
  expect(subject).to receive(:puts).with("Administrator: #{user.properties.administrator}")
  expect(subject).to receive(:puts).with("Force 2-Factor Auth: #{user.properties.force_sec_auth}")
  expect(subject).to receive(:puts).with("2-Factor Auth Active: #{user.properties.sec_auth_active}")
  expect(subject).to receive(:puts).with("Active: #{user.properties.active}")
end

def check_required_options(subject)
  required_options = subject.instance_variable_get(:@required_options)

  arrays_without_one_element(required_options).each do |test_case|

    test_case[:array].each { |value| subject.config[value] = 'test' }

    expect(subject).to receive(:puts).with("Missing required parameters #{test_case[:removed]}")
    expect(subject.api_client).not_to receive(:call_api)

    expect { subject.run }.to raise_error(SystemExit) do |error|
      expect(error.status).to eq(1)
    end

    required_options.each { |value| subject.config[value] = nil }
  end
end

def arrays_without_one_element(arr)
  result = [{ array: arr[1..], removed: [arr[0]] }]
  (1..arr.length - 1).each { |i| result.append({ array: arr[0..i - 1] + arr[i + 1..], removed: [arr[i]] }) }
  result
end

def mock_wait_for(subject)
  expect(subject.api_client).to receive(:wait_for).once { true }
end

def mock_call_api(subject, rules)
  rules.each do |rule|
    expect(subject.api_client).to receive(:call_api).once do |method, path, opts|
      result = nil
      received_body = opts[:body].nil? ? opts[:body] : JSON.parse(opts[:body], symbolize_names: true)

      expect(method.to_s).to eq(rule[:method])
      expect(path).to eq(rule[:path])
      expect(opts[:operation]).to eq(rule[:operation])
      expect(opts[:form_params]).to eq(rule[:form_params] || {})
      expect(opts[:return_type]).to eq(rule[:return_type] || 'Object')
      expect(received_body).to eq(rule[:body] || nil)
      expect(opts.slice(*(rule[:options] || {}).keys)).to eql((rule[:options] || {}))

      if rule[:exception]
        raise rule[:exception]
      end

      rule[:result]
    end
  end
  expect(subject.api_client).not_to receive(:call_api)
end
