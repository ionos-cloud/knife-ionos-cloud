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

      check_group_print(subject, group)
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

      check_group_print(subject, group)
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
            exception: Ionoscloud::ApiError.new(code: 404),
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
      check_required_options(subject)
    end
  end
end
