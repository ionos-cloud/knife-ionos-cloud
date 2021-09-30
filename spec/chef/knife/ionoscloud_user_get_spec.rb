require 'spec_helper'
require 'ionoscloud_user_get'

Chef::Knife::IonoscloudUserGet.load_deps

describe Chef::Knife::IonoscloudUserGet do
  before :each do
    subject { Chef::Knife::IonoscloudUserGet.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call UserApi.users_find_by_id' do
      user = user_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        user_id: user.id,
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      check_user_print(subject, user)

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/um/users/#{subject_config[:user_id]}",
            operation: :'UserManagementApi.um_users_find_by_id',
            return_type: 'User',
            result: user,
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
