require 'spec_helper'
require 'profitbricks_firewall_create'

Chef::Knife::ProfitbricksFirewallCreate.load_deps

describe Chef::Knife::ProfitbricksFirewallCreate do
  subject { Chef::Knife::ProfitbricksFirewallCreate.new }

  before :each do
    @datacenter = create_test_datacenter()
    @server = create_test_server(@datacenter)
    @nic = create_test_nic(@datacenter, @server)

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  after :each do
    Ionoscloud::DataCenterApi.new.datacenters_delete_with_http_info(@datacenter.id)
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
