$:.unshift File.expand_path('../../lib/chef/knife', __FILE__)
require 'rspec'
require 'chef'

require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start

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
