require 'spec_helper'
require 'ionoscloud_user_delete'

Chef::Knife::IonoscloudUserDelete.load_deps

describe Chef::Knife::IonoscloudUserDelete do
  before :each do
    subject { Chef::Knife::IonoscloudUserDelete.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call UserManagementApi.um_users_delete when the ID is valid' do
      user = user_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [user.id]

      check_user_print(subject, user)
      expect(subject.ui).to receive(:warn).with("Deleted User #{user.id}. Request ID: ")

      expect(subject.api_client).not_to receive(:wait_for)
      expect(subject).to receive(:get_request_id).once
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/um/users/#{user.id}",
            operation: :'UserManagementApi.um_users_find_by_id',
            return_type: 'User',
            result: user,
          },
          {
            method: 'DELETE',
            path: "/um/users/#{user.id}",
            operation: :'UserManagementApi.um_users_delete',
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not call UserManagementApi.um_users_delete when the ID is not valid' do
      user_id = 'invalid_id'
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [user_id]

      expect(subject.ui).to receive(:error).with("User ID #{user_id} not found. Skipping.")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/um/users/#{user_id}",
            operation: :'UserManagementApi.um_users_find_by_id',
            return_type: 'User',
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
