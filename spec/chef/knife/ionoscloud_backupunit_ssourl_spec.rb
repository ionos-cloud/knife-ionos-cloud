require 'spec_helper'
require 'ionoscloud_backupunit_ssourl'

Chef::Knife::IonoscloudBackupunitSsourl.load_deps

describe Chef::Knife::IonoscloudBackupunitSsourl do
  subject { Chef::Knife::IonoscloudBackupunitSsourl.new }

  describe '#run' do
    it 'should call BackupUnitsApi.backupunits_ssourl_get and output the received url when the user ID is valid' do
      backupunit = backupunit_mock
      backupunit_sso = backupunit_sso_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        backupunit_id: backupunit.id,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with(backupunit_sso.sso_url)

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/backupunits/#{backupunit.id}/ssourl",
            operation: :'BackupUnitsApi.backupunits_ssourl_get',
            return_type: 'BackupUnitSSO',
            result: backupunit_sso,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should output an error is the user is not found' do
      backupunit_id = 'invalid_id'
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        backupunit_id: backupunit_id,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      allow(subject).to receive(:puts)
      allow(subject).to receive(:print)

      expect(subject.ui).to receive(:error).with("Backup unit ID #{backupunit_id} not found.")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/backupunits/#{backupunit_id}/ssourl",
            operation: :'BackupUnitsApi.backupunits_ssourl_get',
            return_type: 'BackupUnitSSO',
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
