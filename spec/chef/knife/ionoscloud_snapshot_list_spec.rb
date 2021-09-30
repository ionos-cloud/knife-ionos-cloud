require 'spec_helper'
require 'ionoscloud_snapshot_list'

Chef::Knife::IonoscloudSnapshotList.load_deps

describe Chef::Knife::IonoscloudSnapshotList do
  before :each do
    subject { Chef::Knife::IonoscloudSnapshotList.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call SnapshotApi.snapshots_get' do
      snapshots = snapshots_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      snapshot_list = [
        subject.ui.color('ID', :bold),
        subject.ui.color('Name', :bold),
        subject.ui.color('Description', :bold),
        subject.ui.color('Location', :bold),
        subject.ui.color('Size', :bold),
        snapshots.items.first.id,
        snapshots.items.first.properties.name,
        snapshots.items.first.properties.description || '',
        snapshots.items.first.properties.location,
        snapshots.items.first.properties.size.to_s,
      ]

      expect(subject.ui).to receive(:list).with(snapshot_list, :uneven_columns_across, 5)

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: '/snapshots',
            operation: :'SnapshotApi.snapshots_get',
            return_type: 'Snapshots',
            result: snapshots,
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
