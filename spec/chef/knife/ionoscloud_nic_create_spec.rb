require 'spec_helper'
require 'ionoscloud_nic_create'

Chef::Knife::IonoscloudNicCreate.load_deps

describe Chef::Knife::IonoscloudNicCreate do
  before :each do
    subject { Chef::Knife::IonoscloudNicCreate.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call NetworkInterfacesApi.datacenters_servers_nics_post with the expected arguments and output based on what it receives' do
      nic = nic_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        server_id: 'server_id',
        lan: nic.properties.lan,
        name: nic.properties.name,
        dhcp: nic.properties.dhcp,
        ips: nic.properties.ips.join(','),
        firewall_type: 'INGRESS',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expected_body = nic.properties.to_hash
      expected_body.delete(:firewallActive)
      expected_body.delete(:mac)
      expected_body.delete(:deviceNumber)
      expected_body.delete(:pciSlot)

      expect(subject).to receive(:puts).with("ID: #{nic.id}")
      expect(subject).to receive(:puts).with("Name: #{nic.properties.name}")
      expect(subject).to receive(:puts).with("IPs: #{nic.properties.ips.to_s}")
      expect(subject).to receive(:puts).with("DHCP: #{nic.properties.dhcp}")
      expect(subject).to receive(:puts).with("LAN: #{nic.properties.lan}")
      expect(subject).to receive(:puts).with("Firewall Type: #{nic.properties.firewall_type}")
      expect(subject).to receive(:puts).with("Device Number: #{nic.properties.device_number}")
      expect(subject).to receive(:puts).with("PCI Slot: #{nic.properties.pci_slot}")

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'POST',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers/#{subject_config[:server_id]}/nics",
            operation: :'NetworkInterfacesApi.datacenters_servers_nics_post',
            return_type: 'Nic',
            body: { properties: expected_body },
            result: nic,
          },
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers/#{subject_config[:server_id]}/nics/#{nic.id}",
            operation: :'NetworkInterfacesApi.datacenters_servers_nics_find_by_id',
            return_type: 'Nic',
            result: nic,
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
