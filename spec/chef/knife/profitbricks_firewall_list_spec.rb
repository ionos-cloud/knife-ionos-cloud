require 'spec_helper'
require 'profitbricks_firewall_list'

Chef::Knife::ProfitbricksFirewallList.load_deps

describe Chef::Knife::ProfitbricksFirewallList do
  subject { Chef::Knife::ProfitbricksFirewallList.new }

  before :each do
    Ionoscloud.configure do |config|
      config.username = ENV['IONOS_USERNAME']
      config.password = ENV['IONOS_PASSWORD']
    end

    @datacenter, _, headers  = Ionoscloud::DataCenterApi.new.datacenters_post_with_http_info({
      properties: {
        name: 'Chef test Datacenter',
        description: 'Chef test datacenter',
        location: 'de/fra',
      },
    })
    Ionoscloud::ApiClient.new.wait_for { is_done? get_request_id headers }

    @server, _, headers  = Ionoscloud::ServerApi.new.datacenters_servers_post_with_http_info(
      @datacenter.id,
      {
        properties: {
          name: 'Chef test Server',
          ram: 1024,
          cores: 1,
          availabilityZone: 'ZONE_1',
          cpuFamily: 'INTEL_SKYLAKE',
        },
      },
    )
    Ionoscloud::ApiClient.new.wait_for { is_done? get_request_id headers }

    @nic, _, headers  = Ionoscloud::NicApi.new.datacenters_servers_nics_post_with_http_info(
      @datacenter.id,
      @server.id,
      {
        properties: {
          name: 'Chef Test',
          dhcp: true,
          lan: 1,
          firewallActive: true,
          nat: false,
        },
      },
    )
    Ionoscloud::ApiClient.new.wait_for { is_done? get_request_id headers }

    @firewall, _, headers = Ionoscloud::NicApi.new.datacenters_servers_nics_firewallrules_post_with_http_info(
      @datacenter.id,
      @server.id,
      @nic.id,
      {
        properties: {
          name: 'Chef test Firewall',
          protocol: 'TCP',
          portRangeStart: '22',
          portRangeEnd: '22',
        },
      },
    )
    Ionoscloud::ApiClient.new.wait_for { is_done? get_request_id headers }

    {
      profitbricks_username: ENV['IONOS_USERNAME'],
      profitbricks_password: ENV['IONOS_PASSWORD'],
      datacenter_id: @datacenter.id,
      server_id: @server.id,
      nic_id: @nic.id,
    }.each do |key, value|
      subject.config[key] = value
    end

    allow(subject).to receive(:puts)
  end

  after :each do
    _, _, headers  = Ionoscloud::DataCenterApi.new.datacenters_delete_with_http_info(@datacenter.id)
  end

  describe '#run' do
    it 'should output the column headers' do
      expect(subject).to receive(:puts).with(
        %r{(ID\s+Name\s+Protocol\s+Source MAC\s+Source IP\s+Target IP\s+Port Range Start\s+Port Range End\s+ICMP Type\s+ICMP CODE*$\n#{@firewall.id}\s+#{@firewall.properties.name}\s+#{@firewall.properties.protocol}\s+#{@firewall.properties.source_mac}\s+#{@firewall.properties.source_ip}\s+#{@firewall.properties.target_ip}\s+#{@firewall.properties.port_range_start}\s+#{@firewall.properties.port_range_end}\s+#{@firewall.properties.icmp_type}\s+#{@firewall.properties.icmp_code}\s*$)}
      )
      subject.run
    end
  end
end
