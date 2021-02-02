require 'spec_helper'
require 'profitbricks_firewall_create'

Chef::Knife::ProfitbricksFirewallCreate.load_deps

describe Chef::Knife::ProfitbricksFirewallCreate do
  subject { Chef::Knife::ProfitbricksFirewallCreate.new }

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

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  after :each do
    _, _, headers  = Ionoscloud::DataCenterApi.new.datacenters_delete_with_http_info(@datacenter.id)
  end

  describe '#run' do
    it 'should output the column headers' do
      firewall_name = 'Chef test Firewall'
      firewall_protocol = 'TCP'
      firewall_range_start = '22'
      firewall_range_end = '22'

      {
        profitbricks_username: ENV['IONOS_USERNAME'],
        profitbricks_password: ENV['IONOS_PASSWORD'],
        datacenter_id: @datacenter.id,
        server_id: @server.id,
        nic_id: @nic.id,
        name: firewall_name,
        protocol: firewall_protocol,
        portrangestart: firewall_range_start,
        portrangeend: firewall_range_end,
      }.each do |key, value|
        subject.config[key] = value
      end
      expect(subject).to receive(:puts).with("Name: #{firewall_name}")
      expect(subject).to receive(:puts).with("Protocol: #{firewall_protocol}")
      expect(subject).to receive(:puts).with('Source MAC: ')
      expect(subject).to receive(:puts).with('Source IP: ')
      expect(subject).to receive(:puts).with('Target IP: ')
      expect(subject).to receive(:puts).with("Port Range Start: #{firewall_range_start}")
      expect(subject).to receive(:puts).with("Port Range End: #{firewall_range_end}")
      expect(subject).to receive(:puts).with('ICMP Type: ')
      expect(subject).to receive(:puts).with('ICMP Code: ')

      subject.run

      firewall = Ionoscloud::NicApi.new.datacenters_servers_nics_firewallrules_get(@datacenter.id, @server.id, @nic.id, {depth: 1}).items.first
      expect(firewall.properties.name).to eq(firewall_name)
      expect(firewall.properties.protocol).to eq(firewall_protocol)
      expect(firewall.properties.port_range_start.to_s).to eq(firewall_range_start)
      expect(firewall.properties.port_range_end.to_s).to eq(firewall_range_end)
      expect(firewall.metadata.state).to eq('AVAILABLE')
      expect(firewall.metadata.created_by).to eq(ENV['IONOS_USERNAME'])
      expect(firewall.metadata.last_modified_by).to eq(ENV['IONOS_USERNAME'])
    end
  end
end
