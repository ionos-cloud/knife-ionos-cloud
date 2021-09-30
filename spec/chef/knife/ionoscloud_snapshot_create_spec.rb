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
    it 'should call VolumeApi.datacenters_volumes_create_snapshot_post with the expected arguments and output based on what it receives' do
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

      check_snapshot_print(subject, snapshot)

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'POST',
            path: "/datacenters/#{subject_config[:datacenter_id]}/volumes/#{subject_config[:volume_id]}/create-snapshot",
            operation: :'VolumeApi.datacenters_volumes_create_snapshot_post',
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
