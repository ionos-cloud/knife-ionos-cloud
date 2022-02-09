require 'spec_helper'
require 'ionoscloud_s3key_create'

Chef::Knife::IonoscloudS3keyCreate.load_deps

describe Chef::Knife::IonoscloudS3keyCreate do
  before :each do
    subject { Chef::Knife::IonoscloudS3keyCreate.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call UserS3KeysApi.um_users_s3keys_post with the expected arguments and output based on what it receives' do
      s3_key = s3_key_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        user_id: 'user_id',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{s3_key.id}")
      expect(subject).to receive(:puts).with("Secret Key: #{s3_key.properties.secret_key}")
      expect(subject).to receive(:puts).with("Active: #{s3_key.properties.active}")

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'POST',
            path: "/um/users/#{subject_config[:user_id]}/s3keys",
            operation: :'UserS3KeysApi.um_users_s3keys_post',
            return_type: 'S3Key',
            result: s3_key,
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
