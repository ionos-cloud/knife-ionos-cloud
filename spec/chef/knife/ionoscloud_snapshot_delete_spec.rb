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
    it 'should call SnapshotApi.snapshots_delete when the ID is valid' do
      snapshot = snapshot_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [snapshot.id]

      check_snapshot_print(subject, snapshot)
      expect(subject.ui).to receive(:warn).with("Deleted Snapshot #{snapshot.id}. Request ID: ")

      expect(subject.api_client).not_to receive(:wait_for)
      expect(subject).to receive(:get_request_id).once
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/snapshots/#{snapshot.id}",
            operation: :'SnapshotApi.snapshots_find_by_id',
            return_type: 'Snapshot',
            result: snapshot,
          },
          {
            method: 'DELETE',
            path: "/snapshots/#{snapshot.id}",
            operation: :'SnapshotApi.snapshots_delete',
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not call SnapshotApi.snapshots_delete when the user ID is not valid' do
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
            operation: :'SnapshotApi.snapshots_find_by_id',
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
