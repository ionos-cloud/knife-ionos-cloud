require 'spec_helper'
require 'ionoscloud_group_create'

Chef::Knife::IonoscloudGroupCreate.load_deps

describe Chef::Knife::IonoscloudGroupCreate do
  before :each do
    subject { Chef::Knife::IonoscloudGroupCreate.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call UserManagementApi.um_groups_post with the expected arguments and output based on what it receives' do
      group = group_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        name: group.properties.name,
        create_data_center: group.properties.create_data_center,
        create_snapshot: group.properties.create_snapshot,
        reserve_ip: group.properties.reserve_ip,
        access_activity_log: group.properties.access_activity_log,
        s3_privilege: group.properties.s3_privilege,
        create_backup_unit: group.properties.create_backup_unit,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{group.id}")
      expect(subject).to receive(:puts).with("Name: #{group.properties.name}")
      expect(subject).to receive(:puts).with("Create Datacenter: #{group.properties.create_data_center.to_s}")
      expect(subject).to receive(:puts).with("Create Snapshot: #{group.properties.create_snapshot.to_s}")
      expect(subject).to receive(:puts).with("Reserve IP: #{group.properties.reserve_ip.to_s}")
      expect(subject).to receive(:puts).with("Access Activity Log: #{group.properties.access_activity_log.to_s}")
      expect(subject).to receive(:puts).with("S3 Privilege: #{group.properties.s3_privilege.to_s}")
      expect(subject).to receive(:puts).with("Create Backup Unit: #{group.properties.create_backup_unit.to_s}")

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'POST',
            path: '/um/groups',
            operation: :'UserManagementApi.um_groups_post',
            return_type: 'Group',
            body: { properties: group.properties.to_hash },
            result: group,
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
