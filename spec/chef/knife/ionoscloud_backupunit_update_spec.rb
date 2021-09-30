require 'spec_helper'
require 'ionoscloud_backupunit_update'

Chef::Knife::IonoscloudBackupunitUpdate.load_deps

describe Chef::Knife::IonoscloudBackupunitUpdate do
  before :each do
    subject { Chef::Knife::IonoscloudBackupunitUpdate.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call BackupUnitApi.backupunits_patch' do
      backupunit = backupunit_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        backupunit_id: backupunit.id,
        email: 'edited' + backupunit.properties.email,
        password: 'password_edited',
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }


      expect(subject).to receive(:puts).with("ID: #{backupunit.id}")
      expect(subject).to receive(:puts).with("Name: #{backupunit.properties.name}")
      expect(subject).to receive(:puts).with("Email: #{subject_config[:email]}")

      backupunit.properties.email = subject_config[:email]

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'PATCH',
            path: "/backupunits/#{backupunit.id}",
            operation: :'BackupUnitApi.backupunits_patch',
            return_type: 'BackupUnit',
            body: { email: subject_config[:email], password: subject_config[:password] },
            result: backupunit,
          },
          {
            method: 'GET',
            path: "/backupunits/#{backupunit.id}",
            operation: :'BackupUnitApi.backupunits_find_by_id',
            return_type: 'BackupUnit',
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
