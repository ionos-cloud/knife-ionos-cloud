require 'spec_helper'
require 'ionoscloud_snapshot_create'

Chef::Knife::IonoscloudSnapshotCreate.load_deps

describe Chef::Knife::IonoscloudSnapshotCreate do
  before :each do
    subject { Chef::Knife::IonoscloudSnapshotCreate.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call VolumesApi.datacenters_volumes_create_snapshot_post with the expected arguments and output based on what it receives' do
      snapshot = snapshot_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        volume_id: 'volume_id',
        name: snapshot_mock.properties.name,
        description: snapshot_mock.properties.description,
        licence_type: snapshot_mock.properties.licence_type,
        sec_auth_protection: snapshot_mock.properties.sec_auth_protection,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{snapshot.id}")
      expect(subject).to receive(:puts).with("Name: #{snapshot.properties.name}")
      expect(subject).to receive(:puts).with("Description: #{snapshot.properties.description}")
      expect(subject).to receive(:puts).with("Location: #{snapshot.properties.location}")
      expect(subject).to receive(:puts).with("Size: #{snapshot.properties.size.to_s}")
      expect(subject).to receive(:puts).with("Sec Auth Protection: #{snapshot.properties.sec_auth_protection}")
      expect(subject).to receive(:puts).with("License Type: #{snapshot.properties.licence_type}")
      expect(subject).to receive(:puts).with("CPU Hot Plug: #{snapshot.properties.cpu_hot_plug}")
      expect(subject).to receive(:puts).with("CPU Hot Unplug: #{snapshot.properties.cpu_hot_unplug}")
      expect(subject).to receive(:puts).with("RAM Hot Plug: #{snapshot.properties.ram_hot_plug}")
      expect(subject).to receive(:puts).with("RAM Hot Unplug: #{snapshot.properties.ram_hot_unplug}")
      expect(subject).to receive(:puts).with("NIC Hot Plug: #{snapshot.properties.nic_hot_plug}")
      expect(subject).to receive(:puts).with("NIC Hot Unplug: #{snapshot.properties.nic_hot_unplug}")
      expect(subject).to receive(:puts).with("Disc Virtio Hot Plug: #{snapshot.properties.disc_virtio_hot_plug}")
      expect(subject).to receive(:puts).with("Disc Virtio Hot Unplug: #{snapshot.properties.disc_virtio_hot_unplug}")
      expect(subject).to receive(:puts).with("Disc Scsi Hot Plug: #{snapshot.properties.disc_scsi_hot_plug}")
      expect(subject).to receive(:puts).with("Disc Scsi Hot Unplug: #{snapshot.properties.disc_scsi_hot_unplug}")

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'POST',
            path: "/datacenters/#{subject_config[:datacenter_id]}/volumes/#{subject_config[:volume_id]}/create-snapshot",
            operation: :'VolumesApi.datacenters_volumes_create_snapshot_post',
            return_type: 'Snapshot',
            result: snapshot,
            form_params: {
              'name' => snapshot_mock.properties.name,
              'description' => snapshot_mock.properties.description,
              'licenceType' => snapshot_mock.properties.licence_type,
              'secAuthProtection' => snapshot_mock.properties.sec_auth_protection,
            },
          },
          {
            method: 'GET',
            path: "/snapshots/#{snapshot.id}",
            operation: :'SnapshotsApi.snapshots_find_by_id',
            return_type: 'Snapshot',
            result: snapshot,
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
