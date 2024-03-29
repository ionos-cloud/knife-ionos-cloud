require 'spec_helper'
require 'ionoscloud_nic_update'

Chef::Knife::IonoscloudNicUpdate.load_deps

describe Chef::Knife::IonoscloudNicUpdate do
  before :each do
    subject { Chef::Knife::IonoscloudNicUpdate.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call NetworkInterfacesApi.datacenters_servers_nics_patch' do
      nic = nic_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        server_id: 'server_id',
        nic_id: nic.id,
        lan: 13,
        name: nic.properties.name + '_edited',
        dhcp: (!nic.properties.dhcp).to_s,
        ips: (nic.properties.ips + ['127.0.0.3']).join(','),
        firewall_type: 'EGRESS',
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{nic.id}")
      expect(subject).to receive(:puts).with("Name: #{subject_config[:name]}")
      expect(subject).to receive(:puts).with("IPs: #{subject_config[:ips].split(',')}")
      expect(subject).to receive(:puts).with("DHCP: #{subject_config[:dhcp]}")
      expect(subject).to receive(:puts).with("LAN: #{subject_config[:lan]}")
      expect(subject).to receive(:puts).with("Firewall Type: #{subject_config[:firewall_type]}")
      expect(subject).to receive(:puts).with("Device Number: #{nic.properties.device_number}")
      expect(subject).to receive(:puts).with("PCI Slot: #{nic.properties.pci_slot}")

      nic.properties.name = subject_config[:name]
      nic.properties.dhcp = subject_config[:dhcp].to_s.downcase == 'true'
      nic.properties.ips = subject_config[:ips].split(',')
      nic.properties.lan = subject_config[:lan]
      nic.properties.firewall_type = subject_config[:firewall_type]

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'PATCH',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers/#{subject_config[:server_id]}/nics/#{subject_config[:nic_id]}",
            operation: :'NetworkInterfacesApi.datacenters_servers_nics_patch',
            return_type: 'Nic',
            body: {
              name: subject_config[:name],
              dhcp: subject_config[:dhcp].to_s.downcase == 'true',
              ips: subject_config[:ips].split(','),
              lan: subject_config[:lan],
              firewallType: subject_config[:firewall_type],
            },
            result: nic,
          },
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers/#{subject_config[:server_id]}/nics/#{subject_config[:nic_id]}",
            operation: :'NetworkInterfacesApi.datacenters_servers_nics_find_by_id',
            return_type: 'Nic',
            result: nic,
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
