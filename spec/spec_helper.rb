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

def contract_mock(opts = {})
  Ionoscloud::Contract.new(
    type: opts[:type] || 'contract',
    properties: Ionoscloud::ContractProperties.new(
      contract_number: opts[:contract_number] || 31884391,
      owner: opts[:owner] || 'user@domain.com',
      reg_domain: opts[:reg_domain] || 'ionos.de',
      status: opts[:status] || 'BILLABLE',
      resource_limits: opts[:resource_limits] || Ionoscloud::ResourceLimits.new(
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
      ),
    ),
  )
end

def ipblock_mock(opts = {})
  Ionoscloud::IpBlock.new(
    id: opts[:id] || SecureRandom.uuid,
    properties: Ionoscloud::IpBlockProperties.new(
      name: opts[:name] || 'Test IpBlock',
      size: opts[:size] || 4,
      location: opts[:location] || 'de/fra',
      ips: opts[:ips] || ['87.106.113.181', '87.106.113.176', '87.106.113.177', '87.106.113.178'],
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
      location: opts[:location] || 'de/fra',
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

def token_mock
  Ionoscloud::Token.new(
    token: 'test_token'
  )
end

def console_mock
  Ionoscloud::RemoteConsoleUrl.new(
    url: 'test_url'
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
      ips: opts[:ips] || ['1.1.1.1', '1.1.1.2'],
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
      source_ip: opts[:source_ip] || '10.9.20.11',
      target_ip: opts[:target_ip] || '10.9.20.11',
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
      ip: opts[:ip] || '1.1.1.1',
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
  'kubeconfig_file_data'
end

def k8s_cluster_mock(opts = {})
  Ionoscloud::KubernetesCluster.new(
    id: opts[:id] || SecureRandom.uuid,
    properties: Ionoscloud::KubernetesClusterProperties.new(
      name: opts[:name] || 'k8s_cluster_name',
      k8s_version: opts[:k8s_version] || '1.15.4,',
      maintenance_window: opts[:maintenance_window] || maintenance_window_mock,
      available_upgrade_versions: opts[:available_upgrade_versions] || ['1.16.4', '1.17.7'],
      viable_node_pool_versions: opts[:viable_node_pool_versions] || ['1.17.7', '1.18.2']
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

def k8s_nodepool_mock(opts = {})
  Ionoscloud::KubernetesNodePool.new(
    id: opts[:id] || SecureRandom.uuid,
    properties: Ionoscloud::KubernetesNodePoolProperties.new(
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
      labels: opts[:labels] || nil,
      annotations: opts[:annotations] || nil,
      public_ips: opts[:public_ips] || ['81.173.1.2', '82.231.2.5', '92.221.2.4'],
      available_upgrade_versions: opts[:available_upgrade_versions] || ['1.16.4', '1.17.7'],
    ),
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
      public_ip: opts[:public_ip] || '1.1.1.1',
      k8s_version: opts[:k8s_version] || '1.17.7',
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
      location: opts[:location] || 'de/fra',
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
      location: opts[:location] || 'de/fra',
      size: opts[:size] || 10.0,
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

def template_mock(opts = {})
  Ionoscloud::Template.new(
    id: opts[:id] || SecureRandom.uuid,
    properties: Ionoscloud::TemplateProperties.new(
      name: opts[:name] || 'template_name',
      cores: opts[:cores] || 2.0,
      ram: opts[:ram] || 2048.0,
      storage_size: opts[:storage_size] || 100.0,
    ),
  )
end

def templates_mock(opts = {})
  Ionoscloud::Templates.new(
    id: 'templates',
    type: 'collection',
    items: [template_mock, template_mock],
  )
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
      expect(opts[:return_type]).to eq(rule[:return_type] || nil)
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
