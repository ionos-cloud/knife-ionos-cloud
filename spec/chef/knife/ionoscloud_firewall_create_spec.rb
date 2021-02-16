require 'spec_helper'
require 'ionoscloud_firewall_create'

Chef::Knife::IonoscloudFirewallCreate.load_deps

describe Chef::Knife::IonoscloudFirewallCreate do
  subject { Chef::Knife::IonoscloudFirewallCreate.new }

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
    it 'should create the UDP firewall' do
      firewall_name = 'Chef test Firewall'
      firewall_protocol = 'UDP'
      firewall_range_start = '22'
      firewall_range_end = '22'
      source_mac = '01:23:45:67:89:00'
      source_ip = '10.9.20.11'
      target_ip = @nic.properties.ips.first

      {
        ionoscloud_username: ENV['IONOS_USERNAME'],
        ionoscloud_password: ENV['IONOS_PASSWORD'],
        datacenter_id: @datacenter.id,
        server_id: @server.id,
        nic_id: @nic.id,
        name: firewall_name,
        protocol: firewall_protocol,
        portrangestart: firewall_range_start,
        portrangeend: firewall_range_end,
        sourcemac: source_mac,
        sourceip: source_ip,
        targetip: target_ip,
      }.each do |key, value|
        subject.config[key] = value
      end
      expect(subject).to receive(:puts).with("Name: #{firewall_name}")
      expect(subject).to receive(:puts).with("Protocol: #{firewall_protocol}")
      expect(subject).to receive(:puts).with("Source MAC: #{source_mac}")
      expect(subject).to receive(:puts).with("Source IP: #{source_ip}")
      expect(subject).to receive(:puts).with("Target IP: #{target_ip}")
      expect(subject).to receive(:puts).with("Port Range Start: #{firewall_range_start}")
      expect(subject).to receive(:puts).with("Port Range End: #{firewall_range_end}")
      expect(subject).to receive(:puts).with('ICMP Type: ')
      expect(subject).to receive(:puts).with('ICMP Code: ')

      subject.run

      firewall = Ionoscloud::NicApi.new.datacenters_servers_nics_firewallrules_get(@datacenter.id, @server.id, @nic.id, { depth: 1 }).items.first
      expect(firewall.properties.name).to eq(firewall_name)
      expect(firewall.properties.protocol).to eq(firewall_protocol)
      expect(firewall.properties.port_range_start.to_s).to eq(firewall_range_start)
      expect(firewall.properties.port_range_end.to_s).to eq(firewall_range_end)
      expect(firewall.properties.source_mac).to eq(source_mac)
      expect(firewall.properties.source_ip).to eq(source_ip)
      expect(firewall.properties.target_ip).to eq(target_ip)
      expect(firewall.properties.icmp_type).to be_nil
      expect(firewall.properties.icmp_code).to be_nil
      expect(firewall.metadata.state).to eq('AVAILABLE')
      expect(firewall.metadata.created_by).to eq(ENV['IONOS_USERNAME'])
      expect(firewall.metadata.last_modified_by).to eq(ENV['IONOS_USERNAME'])
    end

    it 'should create the ICMP firewall' do
      firewall_name = 'Chef test Firewall'
      firewall_protocol = 'ICMP'
      source_mac = '01:23:45:67:89:00'
      source_ip = '10.9.20.11'
      target_ip = @nic.properties.ips.first
      icmp_type = 4
      icmp_code = 7

      {
        ionoscloud_username: ENV['IONOS_USERNAME'],
        ionoscloud_password: ENV['IONOS_PASSWORD'],
        datacenter_id: @datacenter.id,
        server_id: @server.id,
        nic_id: @nic.id,
        name: firewall_name,
        protocol: firewall_protocol,
        sourcemac: source_mac,
        sourceip: source_ip,
        targetip: target_ip,
        icmptype: icmp_type,
        icmpcode: icmp_code,
      }.each do |key, value|
        subject.config[key] = value
      end
      expect(subject).to receive(:puts).with("Name: #{firewall_name}")
      expect(subject).to receive(:puts).with("Protocol: #{firewall_protocol}")
      expect(subject).to receive(:puts).with("Source MAC: #{source_mac}")
      expect(subject).to receive(:puts).with("Source IP: #{source_ip}")
      expect(subject).to receive(:puts).with("Target IP: #{target_ip}")
      expect(subject).to receive(:puts).with('Port Range Start: ')
      expect(subject).to receive(:puts).with('Port Range End: ')
      expect(subject).to receive(:puts).with("ICMP Type: #{icmp_type}")
      expect(subject).to receive(:puts).with("ICMP Code: #{icmp_code}")

      subject.run

      firewall = Ionoscloud::NicApi.new.datacenters_servers_nics_firewallrules_get(@datacenter.id, @server.id, @nic.id, { depth: 1 }).items.first
      expect(firewall.properties.name).to eq(firewall_name)
      expect(firewall.properties.protocol).to eq(firewall_protocol)
      expect(firewall.properties.port_range_start).to be_nil
      expect(firewall.properties.port_range_end).to be_nil
      expect(firewall.properties.source_mac).to eq(source_mac)
      expect(firewall.properties.source_ip).to eq(source_ip)
      expect(firewall.properties.target_ip).to eq(target_ip)
      expect(firewall.properties.icmp_type).to eq(icmp_type)
      expect(firewall.properties.icmp_code).to eq(icmp_code)
      expect(firewall.metadata.state).to eq('AVAILABLE')
      expect(firewall.metadata.created_by).to eq(ENV['IONOS_USERNAME'])
      expect(firewall.metadata.last_modified_by).to eq(ENV['IONOS_USERNAME'])
    end
  end
end
