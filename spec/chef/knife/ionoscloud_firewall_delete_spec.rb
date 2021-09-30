require 'spec_helper'
require 'ionoscloud_firewall_delete'

Chef::Knife::IonoscloudFirewallDelete.load_deps

describe Chef::Knife::IonoscloudFirewallDelete do
  before :each do
    subject { Chef::Knife::IonoscloudFirewallDelete.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call NicApi.datacenters_servers_nics_firewallrules_firewallrules_delete when the ID is valid' do
      firewall = firewall_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        server_id: 'server_id',
        nic_id: 'nic_id',
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [firewall.id]

      check_firewall_print(subject, firewall)
      expect(subject.ui).to receive(:warn).with("Deleted Firewall rule #{firewall.id}. Request ID: ")

      expect(subject.api_client).not_to receive(:wait_for)
      expect(subject).to receive(:get_request_id).once
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
          {
            method: 'DELETE',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers/#{subject_config[:server_id]}/"\
                  "nics/#{subject_config[:nic_id]}/firewallrules/#{firewall.id}",
            operation: :'NicApi.datacenters_servers_nics_firewallrules_delete',
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not call NicApi.datacenters_servers_nics_firewallrules_delete when the user ID is not valid' do
      firewall_id = 'invalid_id'
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        server_id: 'server_id',
        nic_id: 'nic_id',
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [firewall_id]

      expect(subject.ui).to receive(:error).with("Firewall rule ID #{firewall_id} not found. Skipping.")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers/#{subject_config[:server_id]}/"\
                  "nics/#{subject_config[:nic_id]}/firewallrules/#{firewall_id}",
            operation: :'NicApi.datacenters_servers_nics_firewallrules_find_by_id',
            return_type: 'FirewallRule',
            exception: Ionoscloud::ApiError.new(code: 404),
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
