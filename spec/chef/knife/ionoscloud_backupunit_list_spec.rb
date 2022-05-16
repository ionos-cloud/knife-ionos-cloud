require 'spec_helper'
require 'ionoscloud_backupunit_list'

Chef::Knife::IonoscloudBackupunitList.load_deps

describe Chef::Knife::IonoscloudBackupunitList do
  before :each do
    subject { Chef::Knife::IonoscloudBackupunitList.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call KubernetesApi.k8s_get' do
      backupunits = backupunits_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      backupunit_list = [
        subject.ui.color('ID', :bold),
        subject.ui.color('Name', :bold),
        subject.ui.color('Email', :bold),
        backupunits.items.first.id,
        backupunits.items.first.properties.name,
        backupunits.items.first.properties.email,
        backupunits.items[1].id,
        backupunits.items[1].properties.name,
        backupunits.items[1].properties.email,
      ]

      expect(subject.ui).to receive(:list).with(backupunit_list, :uneven_columns_across, 3)

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: '/backupunits',
            operation: :'BackupUnitsApi.backupunits_get',
            return_type: 'BackupUnits',
            result: backupunits,
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
