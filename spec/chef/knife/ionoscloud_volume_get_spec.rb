require 'spec_helper'
require 'ionoscloud_volume_get'

Chef::Knife::IonoscloudVolumeGet.load_deps

describe Chef::Knife::IonoscloudVolumeGet do
  before :each do
    subject { Chef::Knife::IonoscloudVolumeGet.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call VolumesApi.datacenters_volumes_find_by_id' do
      volume = volume_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        volume_id: volume.id,
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{volume.id}")
      expect(subject).to receive(:puts).with("Name: #{volume.properties.name}")
      expect(subject).to receive(:puts).with("Size: #{volume.properties.size}")
      expect(subject).to receive(:puts).with("Bus: #{volume.properties.bus}")
      expect(subject).to receive(:puts).with("Image: #{volume.properties.image}")
      expect(subject).to receive(:puts).with("Type: #{volume.properties.type}")
      expect(subject).to receive(:puts).with("Licence Type: #{volume.properties.licence_type}")
      expect(subject).to receive(:puts).with("Backupunit ID: #{volume.properties.backupunit_id}")
      expect(subject).to receive(:puts).with("User Data: #{volume.properties.user_data}")
      expect(subject).to receive(:puts).with("Zone: #{volume.properties.availability_zone}")
      expect(subject).to receive(:puts).with("CPU Hot Plug: #{volume.properties.cpu_hot_plug}")
      expect(subject).to receive(:puts).with("RAM Hot Plug: #{volume.properties.ram_hot_plug}")
      expect(subject).to receive(:puts).with("NIC Hot Plug: #{volume.properties.nic_hot_plug}")
      expect(subject).to receive(:puts).with("NIC Hot Unplug: #{volume.properties.nic_hot_unplug}")
      expect(subject).to receive(:puts).with("Disc Virtio Hot Plug: #{volume.properties.disc_virtio_hot_plug}")
      expect(subject).to receive(:puts).with("Disc Virtio Hot Unplug: #{volume.properties.disc_virtio_hot_unplug}")
      expect(subject).to receive(:puts).with("Device number: #{volume.properties.device_number}")
      expect(subject).to receive(:puts).with("PCI Slot: #{volume.properties.pci_slot}")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/volumes/#{subject_config[:volume_id]}",
            operation: :'VolumesApi.datacenters_volumes_find_by_id',
            return_type: 'Volume',
            result: volume,
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
