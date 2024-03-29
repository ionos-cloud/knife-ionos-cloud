require 'spec_helper'
require 'ionoscloud_nic_list'

Chef::Knife::IonoscloudNicList.load_deps

describe Chef::Knife::IonoscloudNicList do
  before :each do
    subject { Chef::Knife::IonoscloudNicList.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call NetworkInterfacesApi.datacenters_servers_nics_get' do
      nics = nics_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        server_id: 'server_id',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      nic_list = [
        subject.ui.color('ID', :bold),
        subject.ui.color('Name', :bold),
        subject.ui.color('IPs', :bold),
        subject.ui.color('DHCP', :bold),
        subject.ui.color('LAN', :bold),
        subject.ui.color('Firewall Type', :bold),
        subject.ui.color('Device Number', :bold),
        subject.ui.color('PCI Slot', :bold),
        nics.items.first.id,
        nics.items.first.properties.name,
        nics.items.first.properties.ips.to_s,
        nics.items.first.properties.dhcp.to_s,
        nics.items.first.properties.lan.to_s,
        nics.items.first.properties.firewall_type.to_s,
        nics.items.first.properties.device_number.to_s,
        nics.items.first.properties.pci_slot.to_s,
        nics.items[1].id,
        nics.items[1].properties.name,
        nics.items[1].properties.ips.to_s,
        nics.items[1].properties.dhcp.to_s,
        nics.items[1].properties.lan.to_s,
        nics.items[1].properties.firewall_type.to_s,
        nics.items[1].properties.device_number.to_s,
        nics.items[1].properties.pci_slot.to_s,
      ]

      expect(subject.ui).to receive(:list).with(nic_list, :uneven_columns_across, 8)

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers/#{subject_config[:server_id]}/nics",
            operation: :'NetworkInterfacesApi.datacenters_servers_nics_get',
            return_type: 'Nics',
            result: nics,
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
