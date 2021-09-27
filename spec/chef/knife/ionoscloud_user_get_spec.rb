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

      expect(subject).to receive(:puts).with("ID: #{user.id}")
      expect(subject).to receive(:puts).with("Firstname: #{user.properties.firstname}")
      expect(subject).to receive(:puts).with("Lastname: #{user.properties.lastname}")
      expect(subject).to receive(:puts).with("Email: #{user.properties.email}")
      expect(subject).to receive(:puts).with("Administrator: #{user.properties.administrator}")
      expect(subject).to receive(:puts).with("Force 2-Factor Auth: #{user.properties.force_sec_auth}")
      expect(subject).to receive(:puts).with("2-Factor Auth Active: #{user.properties.sec_auth_active}")
      expect(subject).to receive(:puts).with("Active: #{user.properties.active}")

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
