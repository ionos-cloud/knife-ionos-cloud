require 'spec_helper'
require 'ionoscloud_user_ssourl'

Chef::Knife::IonoscloudUserSsourl.load_deps

describe Chef::Knife::IonoscloudUserSsourl do
  subject { Chef::Knife::IonoscloudUserSsourl.new }

  describe '#run' do
    it 'should call UserManagementApi.um_users_ssourl_get and output the received url when the user ID is valid' do
      user = user_mock
      sso_url = sso_url_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        user_id: user.id,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with(sso_url.sso_url)

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/um/users/#{user.id}/s3ssourl",
            operation: :'UserManagementApi.um_users_s3ssourl_get',
            return_type: 'S3ObjectStorageSSO',
            result: sso_url,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should output an error is the user is not found' do
      user_id = 'invalid_id'
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        user_id: user_id,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      allow(subject).to receive(:puts)
      allow(subject).to receive(:print)

      expect(subject.ui).to receive(:error).with("User ID #{user_id} not found.")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/um/users/#{user_id}/s3ssourl",
            operation: :'UserManagementApi.um_users_s3ssourl_get',
            return_type: 'S3ObjectStorageSSO',
            exception: Ionoscloud::ApiError.new(code: 404),
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not make any call if any required option is missing' do
      required_options = subject.instance_variable_get(:@required_options)
      allow(subject).to receive(:puts)
      allow(subject).to receive(:print)

      arrays_without_one_element(required_options).each {
        |test_case|

        test_case[:array].each { |value| subject.config[value] = 'test' }

        expect(subject).to receive(:puts).with("Missing required parameters #{test_case[:removed]}")
        expect(subject.api_client).not_to receive(:call_api)

        expect { subject.run }.to raise_error(SystemExit) do |error|
          expect(error.status).to eq(1)
        end

        required_options.each { |value| subject.config[value] = nil }
      }
    end
  end
end
