require 'spec_helper'
require 'ionoscloud_user_create'

Chef::Knife::IonoscloudUserCreate.load_deps

describe Chef::Knife::IonoscloudUserCreate do
  before :each do
    subject { Chef::Knife::IonoscloudUserCreate.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call UserManagementApi.um_users_post with the expected arguments and output based on what it receives' do
      user = user_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        firstname: user.properties.firstname,
        lastname: user.properties.lastname,
        email: user.properties.email,
        password: user.properties.password,
        administrator: user.properties.administrator,
        force_sec_auth: user.properties.force_sec_auth,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{user.id}")
      expect(subject).to receive(:puts).with("Firstname: #{user.properties.firstname}")
      expect(subject).to receive(:puts).with("Lastname: #{user.properties.lastname}")
      expect(subject).to receive(:puts).with("Email: #{user.properties.email}")
      expect(subject).to receive(:puts).with("Administrator: #{user.properties.administrator}")
      expect(subject).to receive(:puts).with("Force 2-Factor Auth: #{user.properties.force_sec_auth}")
      expect(subject).to receive(:puts).with("2-Factor Auth Active: #{user.properties.sec_auth_active}")
      expect(subject).to receive(:puts).with("Active: #{user.properties.active}")

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'POST',
            path: '/um/users',
            operation: :'UserManagementApi.um_users_post',
            return_type: 'User',
            body: { properties: user.properties.to_hash },
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
