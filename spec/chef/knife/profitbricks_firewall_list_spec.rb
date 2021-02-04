require 'spec_helper'
require 'profitbricks_firewall_list'

Chef::Knife::ProfitbricksFirewallList.load_deps

describe Chef::Knife::ProfitbricksFirewallList do
  subject { Chef::Knife::ProfitbricksFirewallList.new }

  before :each do
    @datacenter = create_test_datacenter()
    @server = create_test_server(@datacenter)
    @nic = create_test_nic(@datacenter, @server)
    @firewall = create_test_firewall(@datacenter, @server, @nic)

    allow(subject).to receive(:puts)
  end

  after :each do
    Ionoscloud::DataCenterApi.new.datacenters_delete_with_http_info(@datacenter.id)
  end

  describe '#run' do
    it 'should output the column headers' do
      {
        profitbricks_username: ENV['IONOS_USERNAME'],
        profitbricks_password: ENV['IONOS_PASSWORD'],
        datacenter_id: @datacenter.id,
        server_id: @server.id,
        nic_id: @nic.id,
      }.each do |key, value|
        subject.config[key] = value
      end

      expect(subject).to receive(:puts).with(
        %r{(ID\s+Name\s+Protocol\s+Source MAC\s+Source IP\s+Target IP\s+Port Range Start\s+Port Range End\s+ICMP Type\s+ICMP CODE*$\n#{@firewall.id}\s+#{@firewall.properties.name}\s+#{@firewall.properties.protocol}\s+#{@firewall.properties.source_mac}\s+#{@firewall.properties.source_ip}\s+#{@firewall.properties.target_ip}\s+#{@firewall.properties.port_range_start}\s+#{@firewall.properties.port_range_end}\s+#{@firewall.properties.icmp_type}\s+#{@firewall.properties.icmp_code}\s*$)}
      )
      subject.run
    end
  end
end
