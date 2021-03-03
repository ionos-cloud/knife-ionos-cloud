$:.unshift File.expand_path('../../lib/chef/knife', __FILE__)
require 'rspec'
require 'chef'
require 'securerandom'

RSpec.configure do |config|
  config.before(:each) do
    Ionoscloud.configure do |config|
      config.username = ENV['IONOS_USERNAME']
      config.password = ENV['IONOS_PASSWORD']
    end
  end
end

def create_test_datacenter(properties = {})
  datacenter, _, headers  = Ionoscloud::DataCenterApi.new.datacenters_post_with_http_info({
    properties: {
      name: properties[:name] || 'Chef test Datacenter',
      description: properties[:description] || 'Chef test datacenter',
      location: properties[:location] || 'de/fra',
    },
  })
  Ionoscloud::ApiClient.new.wait_for { is_done? get_request_id headers }

  Ionoscloud::DataCenterApi.new.datacenters_find_by_id(datacenter.id)
end

def create_test_server(datacenter, properties = {})
  server, _, headers  = Ionoscloud::ServerApi.new.datacenters_servers_post_with_http_info(
    datacenter.id,
    {
      properties: {
        name: properties[:name] || 'Chef test Server',
        ram: properties[:ram] || 1024,
        cores: properties[:cores] || 1,
        availabilityZone: properties[:availability_zone] || 'ZONE_1',
        cpuFamily: properties[:cpu_family] || 'INTEL_SKYLAKE',
      },
    },
  )
  Ionoscloud::ApiClient.new.wait_for { is_done? get_request_id headers }

  Ionoscloud::ServerApi.new.datacenters_servers_find_by_id(datacenter.id, server.id)
end

def create_test_nic(datacenter, server, properties = {})
  nic, _, headers  = Ionoscloud::NicApi.new.datacenters_servers_nics_post_with_http_info(
    @datacenter.id,
    @server.id,
    {
      properties: {
        name: properties[:name] || 'Chef Test',
        dhcp: properties[:dhcp] || true,
        lan: properties[:lan] || 1,
        firewallActive: properties[:firewall_active] || true,
        nat: properties[:nat] || false,
        ips: properties[:ips],
      },
    },
  )
  Ionoscloud::ApiClient.new.wait_for { is_done? get_request_id headers }

  Ionoscloud::NicApi.new.datacenters_servers_nics_find_by_id(@datacenter.id, @server.id, nic.id)
end

def create_test_lan(datacenter, properties = {})
  lan, _, headers  = Ionoscloud::LanApi.new.datacenters_lans_post_with_http_info(
    datacenter.id,
    {
      properties: {
        name: properties[:name] || 'Chef test Lan',
        public: properties[:public] || true,
    },
  })
  Ionoscloud::ApiClient.new.wait_for { is_done? get_request_id headers }
  
  Ionoscloud::LanApi.new.datacenters_lans_find_by_id(datacenter.id, lan.id)
end

def create_test_firewall(datacenter, server, nic, properties = {})
  firewall, _, headers = Ionoscloud::NicApi.new.datacenters_servers_nics_firewallrules_post_with_http_info(
    datacenter.id,
    server.id,
    nic.id,
    {
      properties: {
        name: properties[:name] || 'Chef test Firewall',
        protocol: properties[:protocol] || 'TCP',
        portRangeStart: properties[:port_range_start] || '22',
        portRangeEnd: properties[:port_range_end] || '22',
      },
    },
  )
  Ionoscloud::ApiClient.new.wait_for { is_done? get_request_id headers }

  Ionoscloud::NicApi.new.datacenters_servers_nics_firewallrules_find_by_id(
    datacenter.id, server.id, nic.id, firewall.id,
  )
end

def create_test_ipblock(properties = {})
  ip_block, _, headers = Ionoscloud::IPBlocksApi.new.ipblocks_post_with_http_info(
    {
      properties: {
        location: properties[:location] || 'de/fra',
        size: properties[:size] || 1,
      },
    },
  )
  Ionoscloud::ApiClient.new.wait_for { is_done? get_request_id headers }

  Ionoscloud::IPBlocksApi.new.ipblocks_find_by_id(ip_block.id)
end

def create_test_volume(datacenter, properties = {})
  volume, _, headers = Ionoscloud::VolumeApi.new.datacenters_volumes_post_with_http_info(
    datacenter.id,
    {
      properties: {
        name: properties[:name] || 'Test Volume',
        size: properties[:size] || 2,
        type: properties[:type] || 'HDD',
        availabilityZone: properties[:availability_zone] || 'AUTO',
        imageAlias: properties[:image_alias] || 'debian:latest',
        imagePassword: properties[:image_password] || 'K3tTj8G14a3EgKyNeeiY',
      },
    },
  )
  Ionoscloud::ApiClient.new.wait_for { is_done? get_request_id headers }

  Ionoscloud::VolumeApi.new.datacenters_volumes_find_by_id(datacenter.id, volume.id)
end

def create_test_k8s_cluster(properties = {})
  cluster_properties = {
    name: properties[:name] || 'CheftestCluster',
    k8sVersion: properties[:version] || '1.18.15',
  }.compact

  if properties[:maintenance_day] && properties[:maintenance_time]
    cluster_properties[:maintenance_window] = {
      dayOfTheWeek: properties[:maintenance_day],
      time: properties[:maintenance_time],
    }
  end

  cluster, _, headers = Ionoscloud::KubernetesApi.new.k8s_post_with_http_info({ properties: cluster_properties })

  Ionoscloud::ApiClient.new.wait_for { is_done? get_request_id headers }

  Ionoscloud::KubernetesApi.new.k8s_find_by_cluster_id(cluster.id)
end


###################################################################################
################################## NEW MOCKS ######################################
###################################################################################


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

def nic_mock(opts = {})
  Ionoscloud::Nic.new(
    id: opts[:id] || SecureRandom.uuid,
    properties: Ionoscloud::NicProperties.new(
      name: opts[:name] || 'nic_name',
      ips: opts[:ips] || ['1.1.1.1'],
      nat: opts[:nat] || true,
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

def lan_mock(opts = {})
  Ionoscloud::Lan.new(
    id: opts[:id] || '1',
    properties: Ionoscloud::LanProperties.new(
      name: opts[:name] || 'lan_name',
      public: opts[:public] || true,
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

def volume_mock(opts = {})
  Ionoscloud::Volume.new(
    id: opts[:id] || SecureRandom.uuid,
    properties: Ionoscloud::VolumeProperties.new(
      name: opts[:name] || 'volume_name',
      size: opts[:size] || '10.0',
      bus: opts[:bus] || 'VIRTIO',
      image: opts[:image] || 'a3c3c57e-921d-4f81-9dbd-444d571d521d',
      type: opts[:type] || 'SSD',
      licence_type: opts[:licence_type] || 'LINUX',
      availability_zone: opts[:availability_zone] || 'AUTO',
    ),
  )
end

def volumes_mock(opts = {})
  Ionoscloud::Volumes.new(
    id: 'volumes',
    type: 'collection',
    items: [volume_mock],
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
    properties: Ionoscloud::UserProperties.new(
      firstname: opts['firstname'] || 'Firstname',
      lastname: opts['lastname'] || 'Lastname',
      email: opts['email'] || 'a@a.a',
      password: opts['password'] || 'parola1234',
      administrator: opts['administrator'] || false,
      force_sec_auth: opts['force_sec_auth'] || false,
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

def arrays_without_one_element(arr)
  result = [{ array: arr[1..], removed: [arr[0]]}]
  (1..arr.length - 1).each { |i| result.append({ array: arr[0..i-1] + arr[i+1..], removed: [arr[i]]}) }
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

      # puts [received_body, rule[:body]].to_s
  
      expect(method.to_s).to eq(rule[:method])
      expect(path).to eq(rule[:path])
      expect(opts[:operation]).to eq(rule[:operation])
      expect(opts[:form_params]).to eq(rule[:form_params] || {})
      expect(opts[:return_type]).to eq(rule[:return_type] || 'Object')
      expect(received_body).to eq(rule[:body] || nil)
      
      if rule[:exception]
        raise rule[:exception]
      end
      rule[:result]
    end
  end
  expect(subject.api_client).not_to receive(:call_api)
end

def get_request_id(headers)
  headers['Location'].scan(%r{/requests/(\b[0-9a-f]{8}\b-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-\b[0-9a-f]{12}\b)}).last.first
end

def is_done?(request_id)
  response = Ionoscloud::RequestApi.new.requests_status_get(request_id)
  if response.metadata.status == 'FAILED'
    ui.error "Request #{request_id} failed\n" + response.metadata.message
    exit(1)
  end
  response.metadata.status == 'DONE'
end

def cluster_check_state?(cluster_id, target_state = 'ACTIVE')
  cluster = Ionoscloud::KubernetesApi.new.k8s_find_by_cluster_id(cluster_id)
  cluster.metadata.state == target_state
end
