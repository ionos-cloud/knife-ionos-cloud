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
      {
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
      required_options = subject.instance_variable_get(:@required_options)

      if required_options.length > 0
        arrays_without_one_element(required_options).each do |test_case|
          subject.config[:ionoscloud_token] = 'token'
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
end
