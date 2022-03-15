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
    it 'should call FirewallRulesApi.datacenters_servers_nics_firewallrules_firewallrules_delete when the ID is valid' do
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
            operation: :'FirewallRulesApi.datacenters_servers_nics_firewallrules_find_by_id',
            return_type: 'FirewallRule',
            result: firewall,
          },
          {
            method: 'DELETE',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers/#{subject_config[:server_id]}/"\
                  "nics/#{subject_config[:nic_id]}/firewallrules/#{firewall.id}",
            operation: :'FirewallRulesApi.datacenters_servers_nics_firewallrules_delete',
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not call FirewallRulesApi.datacenters_servers_nics_firewallrules_delete when the user ID is not valid' do
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
            operation: :'FirewallRulesApi.datacenters_servers_nics_firewallrules_find_by_id',
            return_type: 'FirewallRule',
            exception: Ionoscloud::ApiError.new(code: 404),
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not make any call if any required option is missing' do
      required_options = subject.instance_variable_get(:@required_options)

      arrays_without_one_element(required_options).each do |test_case|
        test_case[:array].each { |value| subject.config[value] = 'test' }

        expect(subject).to receive(:puts).with("Missing required parameters #{test_case[:removed]}")
        expect(subject.api_client).not_to receive(:call_api)

        expect { subject.run }.to raise_error(SystemExit) do |error|
          expect(error.status).to eq(1)
        end

        required_options.each { |value| subject.config[value] = nil }
      end
    end
  end
end
