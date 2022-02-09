require 'spec_helper'
require 'ionoscloud_backupunit_create'

Chef::Knife::IonoscloudBackupunitCreate.load_deps

describe Chef::Knife::IonoscloudBackupunitCreate do
  before :each do
    subject { Chef::Knife::IonoscloudBackupunitCreate.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call BackupUnitsApi.backupunits_post with the expected arguments and output based on what it receives' do
      backupunit = backupunit_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        name: backupunit.properties.name,
        password: backupunit.properties.password,
        email: backupunit.properties.email,
      }.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{backupunit.id}")
      expect(subject).to receive(:puts).with("Name: #{backupunit.properties.name}")
      expect(subject).to receive(:puts).with("Email: #{backupunit.properties.email}")

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'POST',
            path: '/backupunits',
            operation: :'BackupUnitsApi.backupunits_post',
            return_type: 'BackupUnit',
            body: { properties: backupunit.properties.to_hash },
            result: backupunit,
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
