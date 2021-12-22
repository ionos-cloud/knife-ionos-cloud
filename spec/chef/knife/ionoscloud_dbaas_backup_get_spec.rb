require 'spec_helper'
require 'ionoscloud_dbaas_backup_get'

Chef::Knife::IonoscloudDbaasBackupGet.load_deps

describe Chef::Knife::IonoscloudDbaasBackupGet do
  before :each do
    subject { Chef::Knife::IonoscloudDbaasBackupGet.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call BackupsApi.clusters_backups_find_by_id' do
      backup = cluster_backup_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        backup_id: backup.id,
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{backup.id}")
      expect(subject).to receive(:puts).with("Cluster ID: #{backup.properties.cluster_id}")
      expect(subject).to receive(:puts).with("Display Name: #{backup.properties.display_name}")
      expect(subject).to receive(:puts).with("Is Active: #{backup.properties.is_active}")
      expect(subject).to receive(:puts).with("Version: #{backup.properties.version}")
      expect(subject).to receive(:puts).with("Earliest Recovery Target Time: #{backup.properties.earliest_recovery_target_time}")
      expect(subject).to receive(:puts).with("Created Date: #{backup.metadata.created_date}")

      mock_dbaas_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/clusters/backups/#{backup.id}",
            operation: :'BackupsApi.clusters_backups_find_by_id',
            return_type: 'BackupResponse',
            result: backup,
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
        expect(subject.api_client_dbaas).not_to receive(:call_api)

        expect { subject.run }.to raise_error(SystemExit) do |error|
          expect(error.status).to eq(1)
        end

        required_options.each { |value| subject.config[value] = nil }
      end
    end
  end
end
