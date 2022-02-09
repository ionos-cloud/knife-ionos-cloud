require 'spec_helper'
require 'ionoscloud_backupunit_delete'

Chef::Knife::IonoscloudBackupunitDelete.load_deps

describe Chef::Knife::IonoscloudBackupunitDelete do
  before :each do
    subject { Chef::Knife::IonoscloudBackupunitDelete.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call BackupUnitsApi.backupunits_delete when the ID is valid' do
      backupunit = backupunit_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [backupunit.id]

      expect(subject).to receive(:puts).with("ID: #{backupunit.id}")
      expect(subject).to receive(:puts).with("Name: #{backupunit.properties.name}")
      expect(subject).to receive(:puts).with("Email: #{backupunit.properties.email}")
      expect(subject.ui).to receive(:warn).with("Deleted Backup unit #{backupunit.id}. Request ID: ")

      expect(subject.api_client).not_to receive(:wait_for)
      expect(subject).to receive(:get_request_id).once
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/backupunits/#{backupunit.id}",
            operation: :'BackupUnitsApi.backupunits_find_by_id',
            return_type: 'BackupUnit',
            result: backupunit,
          },
          {
            method: 'DELETE',
            path: "/backupunits/#{backupunit.id}",
            operation: :'BackupUnitsApi.backupunits_delete',
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not call BackupUnitsApi.backupunits_delete when the ID is not valid' do
      backup_unit = 'invalid_id'
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [backup_unit]

      expect(subject.ui).to receive(:error).with("Backup unit ID #{backup_unit} not found. Skipping.")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/backupunits/#{backup_unit}",
            operation: :'BackupUnitsApi.backupunits_find_by_id',
            return_type: 'BackupUnit',
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
