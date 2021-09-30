require 'spec_helper'
require 'ionoscloud_firewall_create'

Chef::Knife::IonoscloudFirewallCreate.load_deps

describe Chef::Knife::IonoscloudFirewallCreate do
  before :each do
    subject { Chef::Knife::IonoscloudFirewallCreate.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call NicApi.datacenters_servers_nics_firewallrules_post with the expected arguments and output based on what it receives' do
      firewall = firewall_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        server_id: 'server_id',
        nic_id: 'nic_id',
        name: firewall.properties.name,
        protocol: firewall.properties.protocol,
        source_mac: firewall.properties.source_mac,
        source_ip: firewall.properties.source_ip,
        target_ip: firewall.properties.target_ip,
        port_range_start: firewall.properties.port_range_start,
        port_range_end: firewall.properties.port_range_end,
        icmp_type: firewall.properties.icmp_type,
        icmp_code: firewall.properties.icmp_code,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      check_firewall_print(subject, firewall)

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'POST',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers/#{subject_config[:server_id]}/nics/#{subject_config[:nic_id]}/firewallrules",
            operation: :'NicApi.datacenters_servers_nics_firewallrules_post',
            return_type: 'FirewallRule',
            body: { properties: firewall.properties.to_hash },
            result: firewall,
          },
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers/#{subject_config[:server_id]}/nics/#{subject_config[:nic_id]}/firewallrules/#{firewall.id}",
            operation: :'NicApi.datacenters_servers_nics_firewallrules_find_by_id',
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
