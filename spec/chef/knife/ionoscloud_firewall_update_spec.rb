require 'spec_helper'
require 'ionoscloud_firewall_update'

Chef::Knife::IonoscloudFirewallUpdate.load_deps

describe Chef::Knife::IonoscloudFirewallUpdate do
  before :each do
    subject { Chef::Knife::IonoscloudFirewallUpdate.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call FirewallRulesApi.datacenters_servers_nics_firewallrules_patch' do
      firewall = firewall_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        server_id: 'server_id',
        nic_id: 'nic_id',
        firewall_id: firewall.id,
        name: firewall.properties.name + '_edited',
        protocol: 'TCP',
        source_mac: '01:11:11:11:22:00',
        source_ip: '127.0.0.3',
        target_ip: '127.0.0.4',
        port_range_start: 100,
        port_range_end: 145,
        icmp_type: 15,
        icmp_code: 14,
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{firewall.id}")
      expect(subject).to receive(:puts).with("Name: #{subject_config[:name]}")
      expect(subject).to receive(:puts).with("Type: #{firewall.properties.type}")
      expect(subject).to receive(:puts).with("Protocol: #{subject_config[:protocol]}")
      expect(subject).to receive(:puts).with("Source MAC: #{subject_config[:source_mac]}")
      expect(subject).to receive(:puts).with("Source IP: #{subject_config[:source_ip]}")
      expect(subject).to receive(:puts).with("Target IP: #{subject_config[:target_ip]}")
      expect(subject).to receive(:puts).with("Port Range Start: #{subject_config[:port_range_start]}")
      expect(subject).to receive(:puts).with("Port Range End: #{subject_config[:port_range_end]}")
      expect(subject).to receive(:puts).with("ICMP Type: #{subject_config[:icmp_type]}")
      expect(subject).to receive(:puts).with("ICMP Code: #{subject_config[:icmp_code]}")

      firewall.properties.name = subject_config[:name]
      firewall.properties.protocol = subject_config[:protocol]
      firewall.properties.source_mac = subject_config[:source_mac]
      firewall.properties.source_ip = subject_config[:source_ip]
      firewall.properties.target_ip = subject_config[:target_ip]
      firewall.properties.port_range_start = subject_config[:port_range_start]
      firewall.properties.port_range_end = subject_config[:port_range_end]
      firewall.properties.icmp_type = subject_config[:icmp_type]
      firewall.properties.icmp_code = subject_config[:icmp_code]

      expected_body = {
        name: subject_config[:name],
        protocol: subject_config[:protocol],
        sourceMac: subject_config[:source_mac],
        sourceIp: subject_config[:source_ip],
        targetIp: subject_config[:target_ip],
        portRangeStart: subject_config[:port_range_start],
        portRangeEnd: subject_config[:port_range_end],
        icmpType: subject_config[:icmp_type],
        icmpCode: subject_config[:icmp_code],
      }

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'PATCH',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers/#{subject_config[:server_id]}/"\
            "nics/#{subject_config[:nic_id]}/firewallrules/#{firewall.id}",
            operation: :'FirewallRulesApi.datacenters_servers_nics_firewallrules_patch',
            return_type: 'FirewallRule',
            body: expected_body,
            result: firewall,
          },
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
      required_options = subject.instance_variable_get(:@required_options)

      if required_options.length > 0
        arrays_without_one_element(required_options).each do |test_case|
          subject.config[:ionoscloud_token] = 'token'
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
end
