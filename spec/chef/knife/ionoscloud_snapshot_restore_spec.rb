require 'spec_helper'
require 'ionoscloud_snapshot_restore'

Chef::Knife::IonoscloudSnapshotRestore.load_deps

describe Chef::Knife::IonoscloudSnapshotRestore do
  before :each do
    subject { Chef::Knife::IonoscloudSnapshotRestore.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call VolumesApi.datacenters_volumes_create_snapshot_post with the expected arguments and output based on what it receives' do
      snapshot = snapshot_mock
      volume = volume_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        volume_id: volume.id,
        snapshot_id: snapshot.id,
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

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'POST',
            path: "/datacenters/#{subject_config[:datacenter_id]}/volumes/#{volume.id}/restore-snapshot",
            operation: :'VolumesApi.datacenters_volumes_restore_snapshot_post',
            form_params: { 'snapshotId' => snapshot.id },
          },
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/volumes/#{volume.id}",
            operation: :'VolumesApi.datacenters_volumes_find_by_id',
            return_type: 'Volume',
            result: volume,
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
