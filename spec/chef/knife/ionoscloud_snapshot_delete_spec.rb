require 'spec_helper'
require 'ionoscloud_snapshot_delete'

Chef::Knife::IonoscloudSnapshotDelete.load_deps

describe Chef::Knife::IonoscloudSnapshotDelete do
  before :each do
    subject { Chef::Knife::IonoscloudSnapshotDelete.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call SnapshotsApi.snapshots_delete when the ID is valid' do
      snapshot = snapshot_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [snapshot.id]

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
      expect(subject.ui).to receive(:warn).with("Deleted Snapshot #{snapshot.id}. Request ID: ")

      expect(subject.api_client).not_to receive(:wait_for)
      expect(subject).to receive(:get_request_id).once
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/snapshots/#{snapshot.id}",
            operation: :'SnapshotsApi.snapshots_find_by_id',
            return_type: 'Snapshot',
            result: snapshot,
          },
          {
            method: 'DELETE',
            path: "/snapshots/#{snapshot.id}",
            operation: :'SnapshotsApi.snapshots_delete',
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not call SnapshotsApi.snapshots_delete when the user ID is not valid' do
      snapshot_id = 'invalid_id'
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [snapshot_id]

      expect(subject.ui).to receive(:error).with("Snapshot ID #{snapshot_id} not found. Skipping.")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/snapshots/#{snapshot_id}",
            operation: :'SnapshotsApi.snapshots_find_by_id',
            return_type: 'Snapshot',
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
