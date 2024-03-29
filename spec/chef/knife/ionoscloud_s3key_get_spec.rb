require 'spec_helper'
require 'ionoscloud_s3key_get'

Chef::Knife::IonoscloudS3keyGet.load_deps

describe Chef::Knife::IonoscloudS3keyGet do
  before :each do
    subject { Chef::Knife::IonoscloudS3keyGet.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call UserS3KeysApi.um_users_s3keys_find_by_key_id' do
      s3_key = s3_key_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        user_id: 'user_id',
        s3_key_id: s3_key.id,
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{s3_key.id}")
      expect(subject).to receive(:puts).with("Secret Key: #{s3_key.properties.secret_key}")
      expect(subject).to receive(:puts).with("Active: #{s3_key.properties.active}")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/um/users/#{subject_config[:user_id]}/s3keys/#{s3_key.id}",
            operation: :'UserS3KeysApi.um_users_s3keys_find_by_key_id',
            return_type: 'S3Key',
            result: s3_key,
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
