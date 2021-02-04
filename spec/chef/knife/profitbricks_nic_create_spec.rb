require 'spec_helper'
require 'profitbricks_nic_create'

Chef::Knife::ProfitbricksNicCreate.load_deps

describe Chef::Knife::ProfitbricksNicCreate do
  subject { Chef::Knife::ProfitbricksNicCreate.new }

  before :each do
    @datacenter = create_test_datacenter()
    @server = create_test_server(@datacenter)

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  after :each do
    Ionoscloud::DataCenterApi.new.datacenters_delete_with_http_info(@datacenter.id)
  end

  describe '#run' do
    it 'should create a nic' do
      nic_name = 'Chef test nic'
      nic_dhcp = true
      nic_lan = 1
      nic_nat = false
  
      {
        profitbricks_username: ENV['IONOS_USERNAME'],
        profitbricks_password: ENV['IONOS_PASSWORD'],
        datacenter_id: @datacenter.id,
        server_id: @server.id,
        name: nic_name,
        dhpc: nic_dhcp,
        lan: nic_lan,
        nat: nic_nat,
      }.each do |key, value|
        subject.config[key] = value
      end

      expect(subject).to receive(:puts).with(/^ID: (\b[0-9a-f]{8}\b-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-\b[0-9a-f]{12})\b$/)
      expect(subject).to receive(:puts).with("Name: #{nic_name}")
      expect(subject).to receive(:puts).with("DHCP: #{nic_dhcp}")
      expect(subject).to receive(:puts).with("LAN: #{nic_lan}")
      expect(subject).to receive(:puts).with("NAT: #{nic_nat}")

      subject.run

      nic = Ionoscloud::NicApi.new.datacenters_servers_nics_get(@datacenter.id, @server.id, {depth: 1}).items.first

      expect(nic.properties.name).to eq(nic_name)
      expect(nic.properties.dhcp).to eq(nic_dhcp)
      expect(nic.properties.lan).to eq(nic_lan)
      expect(nic.properties.nat).to eq(nic_nat)
      expect(nic.metadata.state).to eq('AVAILABLE')
      expect(nic.metadata.created_by).to eq(ENV['IONOS_USERNAME'])
      expect(nic.metadata.last_modified_by).to eq(ENV['IONOS_USERNAME'])
    end
  end
end
