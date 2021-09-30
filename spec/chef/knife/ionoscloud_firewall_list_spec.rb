require 'spec_helper'
require 'ionoscloud_firewall_list'

Chef::Knife::IonoscloudFirewallList.load_deps

describe Chef::Knife::IonoscloudFirewallList do
  before :each do
    subject { Chef::Knife::IonoscloudFirewallList.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call NicApi.datacenters_servers_nics_firewallrules_get' do
      firewalls = firewalls_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        server_id: 'server_id',
        nic_id: 'nic_id',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      firewall_list = [
        subject.ui.color('ID', :bold),
        subject.ui.color('Name', :bold),
        subject.ui.color('Protocol', :bold),
        subject.ui.color('Source MAC', :bold),
        subject.ui.color('Source IP', :bold),
        subject.ui.color('Target IP', :bold),
        subject.ui.color('Port Range Start', :bold),
        subject.ui.color('Port Range End', :bold),
        subject.ui.color('ICMP Type', :bold),
        subject.ui.color('ICMP CODE', :bold),
      ]

      firewalls.items.each do |firewall|
        firewall_list << firewall.id
        firewall_list << firewall.properties.name
        firewall_list << firewall.properties.protocol.to_s
        firewall_list << firewall.properties.source_mac.to_s
        firewall_list << firewall.properties.source_ip.to_s
        firewall_list << firewall.properties.target_ip.to_s
        firewall_list << firewall.properties.port_range_start.to_s
        firewall_list << firewall.properties.port_range_end.to_s
        firewall_list << firewall.properties.icmp_type.to_s
        firewall_list << firewall.properties.icmp_code.to_s
      end

      expect(subject.ui).to receive(:list).with(firewall_list, :uneven_columns_across, 10)

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers/#{subject_config[:server_id]}/"\
                  "nics/#{subject_config[:nic_id]}/firewallrules",
            operation: :'NicApi.datacenters_servers_nics_firewallrules_get',
            return_type: 'FirewallRules',
            result: firewalls,
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
