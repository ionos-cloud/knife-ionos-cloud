require 'spec_helper'
require 'ionoscloud_group_user_add'

Chef::Knife::IonoscloudGroupUserAdd.load_deps

describe Chef::Knife::IonoscloudGroupUserAdd do
  before :each do
    subject { Chef::Knife::IonoscloudGroupUserAdd.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call UserManagementApi.um_groups_users_post when the ID is valid' do
      group = group_mock
      user = user_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        group_id: group.id,
        yes: true,
      }
 
      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [user.id]

      users = group.entities.users.items.map { |user| user.id }

      expect(subject).to receive(:puts).with("ID: #{group.id}")
      expect(subject).to receive(:puts).with("Name: #{group.properties.name}")
      expect(subject).to receive(:puts).with("Create Datacenter: #{group.properties.create_data_center.to_s}")
      expect(subject).to receive(:puts).with("Create Snapshot: #{group.properties.create_snapshot.to_s}")
      expect(subject).to receive(:puts).with("Reserve IP: #{group.properties.reserve_ip.to_s}")
      expect(subject).to receive(:puts).with("Access Activity Log: #{group.properties.access_activity_log.to_s}")
      expect(subject).to receive(:puts).with("S3 Privilege: #{group.properties.s3_privilege.to_s}")
      expect(subject).to receive(:puts).with("Create Backup Unit: #{group.properties.create_backup_unit.to_s}")
      expect(subject).to receive(:puts).with("Users: #{users.to_s}")
      expect(subject.ui).to receive(:info).with("Added User #{user.id} to the Group #{group.id}. Request ID: .")

      expect(subject).to receive(:get_request_id).once
      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'POST',
            path: "/um/groups/#{group.id}/users",
            operation: :'UserManagementApi.um_groups_users_post',
            body: { id: user.id },
            return_type: 'User',
          },
          {
            method: 'GET',
            path: "/um/groups/#{group.id}",
            operation: :'UserManagementApi.um_groups_find_by_id',
            return_type: 'Group',
            result: group,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not call UserManagementApi.um_groups_users_post when the ID is not valid' do
      group = group_mock
      user_id = 'invalid_id'
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        group_id: group.id,
      }
 
      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [user_id]

      users = group.entities.users.items.map { |user| user.id }

      expect(subject).to receive(:puts).with("ID: #{group.id}")
      expect(subject).to receive(:puts).with("Name: #{group.properties.name}")
      expect(subject).to receive(:puts).with("Create Datacenter: #{group.properties.create_data_center.to_s}")
      expect(subject).to receive(:puts).with("Create Snapshot: #{group.properties.create_snapshot.to_s}")
      expect(subject).to receive(:puts).with("Reserve IP: #{group.properties.reserve_ip.to_s}")
      expect(subject).to receive(:puts).with("Access Activity Log: #{group.properties.access_activity_log.to_s}")
      expect(subject).to receive(:puts).with("S3 Privilege: #{group.properties.s3_privilege.to_s}")
      expect(subject).to receive(:puts).with("Create Backup Unit: #{group.properties.create_backup_unit.to_s}")
      expect(subject).to receive(:puts).with("Users: #{users.to_s}")
      expect(subject.ui).to receive(:error).with("User ID #{user_id} not found. Skipping.")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'POST',
            path: "/um/groups/#{subject_config[:group_id]}/users",
            operation: :'UserManagementApi.um_groups_users_post',
            body: { id: user_id },
            return_type: 'User',
            exception: Ionoscloud::ApiError.new(:code => 404),
          },
          {
            method: 'GET',
            path: "/um/groups/#{group.id}",
            operation: :'UserManagementApi.um_groups_find_by_id',
            return_type: 'Group',
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
