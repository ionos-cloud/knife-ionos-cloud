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

      check_user_print(subject, user)

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
