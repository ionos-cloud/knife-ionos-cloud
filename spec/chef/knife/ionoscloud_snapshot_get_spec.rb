require 'spec_helper'
require 'ionoscloud_snapshot_get'

Chef::Knife::IonoscloudSnapshotGet.load_deps

describe Chef::Knife::IonoscloudSnapshotGet do
  before :each do
    subject { Chef::Knife::IonoscloudSnapshotGet.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call SnapshotApi.snapshots_find_by_id' do
      snapshot = snapshot_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        snapshot_id: snapshot.id,
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      check_snapshot_print(subject, snapshot)

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/snapshots/#{subject_config[:snapshot_id]}",
            operation: :'SnapshotApi.snapshots_find_by_id',
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
