require 'spec_helper'
require 'ionoscloud_s3key_delete'

Chef::Knife::IonoscloudS3keyDelete.load_deps

describe Chef::Knife::IonoscloudS3keyDelete do
  before :each do
    subject { Chef::Knife::IonoscloudS3keyDelete.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call UserManagementApi.um_users_s3keys_delete when the ID is valid' do
      s3_key = s3_key_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        user_id: 'user_id',
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [s3_key.id]

      expect(subject).to receive(:puts).with("ID: #{s3_key.id}")
      expect(subject).to receive(:puts).with("Secret Key: #{s3_key.properties.secret_key}")
      expect(subject).to receive(:puts).with("Active: #{s3_key.properties.active}")
      expect(subject.ui).to receive(:warn).with("Deleted S3 key #{s3_key.id}. Request ID: ")

      expect(subject.api_client).not_to receive(:wait_for)
      expect(subject).to receive(:get_request_id).once
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/um/users/#{subject_config[:user_id]}/s3keys/#{s3_key.id}",
            operation: :'UserManagementApi.um_users_s3keys_find_by_key_id',
            return_type: 'S3Key',
            result: s3_key,
          },
          {
            method: 'DELETE',
            path: "/um/users/#{subject_config[:user_id]}/s3keys/#{s3_key.id}",
            operation: :'UserManagementApi.um_users_s3keys_delete',
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not call UserManagementApi.um_users_s3keys_delete when the ID is not valid' do
      s3_key_id = 'invalid_id'
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        user_id: 'user_id',
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [s3_key_id]

      expect(subject.ui).to receive(:error).with("S3 key ID #{s3_key_id} not found. Skipping.")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/um/users/#{subject_config[:user_id]}/s3keys/#{s3_key_id}",
            operation: :'UserManagementApi.um_users_s3keys_find_by_key_id',
            return_type: 'S3Key',
            exception: Ionoscloud::ApiError.new(code: 404),
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
