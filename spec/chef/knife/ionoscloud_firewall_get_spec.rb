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
    it 'should call NicApi.datacenters_servers_nics_firewallrules_find_by_id' do
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

      check_firewall_print(subject, firewall)

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers/#{subject_config[:server_id]}/"\
                  "nics/#{subject_config[:nic_id]}/firewallrules/#{firewall.id}",
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
