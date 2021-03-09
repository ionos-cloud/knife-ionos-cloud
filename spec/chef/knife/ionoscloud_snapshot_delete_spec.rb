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

      expect(subject).to receive(:puts).with("ID: #{snapshot.id}")
      expect(subject).to receive(:puts).with("Name: #{snapshot.properties.name}")
      expect(subject).to receive(:puts).with("Description: #{snapshot.properties.description}")
      expect(subject).to receive(:puts).with("Location: #{snapshot.properties.location}")
      expect(subject).to receive(:puts).with("Size: #{snapshot.properties.size.to_s}")
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
            exception: Ionoscloud::ApiError.new(:code => 404),
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
