require 'spec_helper'
require 'ionoscloud_volume_delete'

Chef::Knife::IonoscloudVolumeDelete.load_deps

describe Chef::Knife::IonoscloudVolumeDelete do
  before :each do
    subject { Chef::Knife::IonoscloudVolumeDelete.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call VolumesApi.datacenters_volumes_delete when the ID is valid' do
      volume = volume_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [volume.id]

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
      expect(subject.ui).to receive(:warn).with("Deleted Volume #{volume.id}. Request ID: ")

      expect(subject).not_to receive(:wait_for)
      expect(subject).to receive(:get_request_id).once
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/volumes/#{volume.id}",
            operation: :'VolumesApi.datacenters_volumes_find_by_id',
            return_type: 'Volume',
            result: volume,
          },
          {
            method: 'DELETE',
            path: "/datacenters/#{subject_config[:datacenter_id]}/volumes/#{volume.id}",
            operation: :'VolumesApi.datacenters_volumes_delete',
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not call VolumesApi.datacenters_volumes_delete when the ID is not valid' do
      volume_id = 'invalid_id'
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [volume_id]

      expect(subject.ui).to receive(:error).with("Volume ID #{volume_id} not found. Skipping.")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/volumes/#{volume_id}",
            operation: :'VolumesApi.datacenters_volumes_find_by_id',
            return_type: 'Volume',
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
