require 'spec_helper'
require 'ionoscloud_firewall_get'

Chef::Knife::IonoscloudFirewallGet.load_deps

describe Chef::Knife::IonoscloudFirewallGet do
  before :each do
    subject { Chef::Knife::IonoscloudFirewallGet.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call FirewallRulesApi.datacenters_servers_nics_firewallrules_find_by_id' do
      firewall = firewall_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        server_id: 'server_id',
        nic_id: 'nic_id',
        firewall_id: firewall.id,
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{firewall.id}")
      expect(subject).to receive(:puts).with("Name: #{firewall.properties.name}")
      expect(subject).to receive(:puts).with("Type: #{firewall.properties.type}")
      expect(subject).to receive(:puts).with("Protocol: #{firewall.properties.protocol}")
      expect(subject).to receive(:puts).with("Source MAC: #{firewall.properties.source_mac}")
      expect(subject).to receive(:puts).with("Source IP: #{firewall.properties.source_ip}")
      expect(subject).to receive(:puts).with("Target IP: #{firewall.properties.target_ip}")
      expect(subject).to receive(:puts).with("Port Range Start: #{firewall.properties.port_range_start}")
      expect(subject).to receive(:puts).with("Port Range End: #{firewall.properties.port_range_end}")
      expect(subject).to receive(:puts).with("ICMP Type: #{firewall.properties.icmp_type}")
      expect(subject).to receive(:puts).with("ICMP Code: #{firewall.properties.icmp_code}")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers/#{subject_config[:server_id]}/"\
                  "nics/#{subject_config[:nic_id]}/firewallrules/#{firewall.id}",
            operation: :'FirewallRulesApi.datacenters_servers_nics_firewallrules_find_by_id',
            return_type: 'FirewallRule',
            result: firewall,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not make any call if any required option is missing' do
      check_required_options(subject)
    end
  end
end
