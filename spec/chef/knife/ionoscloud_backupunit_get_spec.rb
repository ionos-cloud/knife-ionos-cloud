require 'spec_helper'
require 'ionoscloud_backupunit_get'

Chef::Knife::IonoscloudBackupunitGet.load_deps

describe Chef::Knife::IonoscloudBackupunitGet do
  before :each do
    subject { Chef::Knife::IonoscloudBackupunitGet.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call BackupUnitsApi.backupunits_find_by_id' do
      backupunit = backupunit_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        backupunit_id: backupunit.id,
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{backupunit.id}")
      expect(subject).to receive(:puts).with("Name: #{backupunit.properties.name}")
      expect(subject).to receive(:puts).with("Email: #{backupunit.properties.email}")

      expect(subject.api_client).not_to receive(:wait_for)
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
