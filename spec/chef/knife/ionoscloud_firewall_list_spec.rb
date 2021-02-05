require 'spec_helper'
require 'ionoscloud_firewall_list'

Chef::Knife::IonoscloudFirewallList.load_deps

describe Chef::Knife::IonoscloudFirewallList do
  subject { Chef::Knife::IonoscloudFirewallList.new }

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
        ionoscloud_username: ENV['IONOS_USERNAME'],
        ionoscloud_password: ENV['IONOS_PASSWORD'],
        datacenter_id: @datacenter.id,
        server_id: @server.id,
        nic_id: @nic.id,
      }.each do |key, value|
        subject.config[key] = value
      end

      expect(subject).to receive(:puts).with(
        %r{
          (^ID\s+Name\s+Protocol\s+Source\sMAC\s+Source\sIP\s+Target\sIP\s+
          Port\sRange\sStart\s+Port\sRange\sEnd\s+ICMP\sType\s+ICMP\sCODE*$\n
          #{@firewall.id}\s+#{@firewall.properties.name.gsub(' ', '\s')}
          \s+#{@firewall.properties.protocol}\s+#{@firewall.properties.source_mac}
          \s+#{@firewall.properties.source_ip}\s+#{@firewall.properties.target_ip}
          \s+#{@firewall.properties.port_range_start}\s+#{@firewall.properties.port_range_end}
          \s+#{@firewall.properties.icmp_type}\s+#{@firewall.properties.icmp_code}\s*$)
        }x
      )
      subject.run
    end
  end
end
