$:.unshift File.expand_path('../../lib/chef/knife', __FILE__)
require 'rspec'
require 'chef'

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

def sso_url_mock(opts = {})
  Ionoscloud::S3ObjectStorageSSO.new(
    sso_url: opts['sso_url'] || 'www.sso-url.com',
  )
end

def volume_mock(opts = {})
  Ionoscloud::Volume.new(
    id: 'a3c3c57e-921d-4f81-9dbd-444d571d521c',
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

def s3_key_mock(opts = {})
  Ionoscloud::S3Key.new(
    id: 'a3c3c57e-921d-4f81-9dbd-444d571d5212',
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
    id: 'a3c3c57e-921d-4f81-9dbd-444d571d521f',
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
    id: 'a3c3c57e-921d-4f81-9dbd-444d571d5215',
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
    id: 'a3c3c57e-921d-4f81-9dbd-444d571d521b',
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

def user_mock(opts = {})
  Ionoscloud::User.new(
    id: 'a3c3c57e-921d-4f81-9dbd-444d571d521a',
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
