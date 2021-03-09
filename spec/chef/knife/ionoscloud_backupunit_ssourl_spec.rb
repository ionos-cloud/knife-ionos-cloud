require 'spec_helper'
require 'ionoscloud_backupunit_ssourl'

Chef::Knife::IonoscloudBackupunitSsourl.load_deps

describe Chef::Knife::IonoscloudBackupunitSsourl do
  subject { Chef::Knife::IonoscloudBackupunitSsourl.new }

  describe '#run' do
    it 'should call BackupUnitApi.backupunits_ssourl_get and output the received url when the user ID is valid' do
      backupunit = backupunit_mock
      backupunit_sso = backupunit_sso_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        backupunit_id: backupunit.id,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      allow(subject).to receive(:puts)

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/backupunits/#{backupunit.id}/ssourl",
            operation: :'BackupUnitApi.backupunits_ssourl_get',
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

      expect(subject.ui).to receive(:error).with("Backup unit ID #{backupunit_id} not found. Skipping.")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/backupunits/#{backupunit_id}/ssourl",
            operation: :'BackupUnitApi.backupunits_ssourl_get',
            return_type: 'BackupUnitSSO',
            exception: Ionoscloud::ApiError.new(:code => 404),
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not make any call if any required option is missing' do
      required_options = subject.instance_variable_get(:@required_options)
      allow(subject).to receive(:puts)
      allow(subject).to receive(:print)

      arrays_without_one_element(required_options).each {
        |test_case|

        test_case[:array].each { |value| subject.config[value] = 'test' }

        expect(subject).to receive(:puts).with("Missing required parameters #{test_case[:removed]}")
        expect(subject.api_client).not_to receive(:call_api)

        expect { subject.run }.to raise_error(SystemExit) do |error|
          expect(error.status).to eq(1)
        end

        required_options.each { |value| subject.config[value] = nil }
      }
    end
  end
end
