require 'spec_helper'
require 'ionoscloud_s3key_list'

Chef::Knife::IonoscloudS3keyList.load_deps

describe Chef::Knife::IonoscloudS3keyList do
  before :each do
    subject { Chef::Knife::IonoscloudS3keyList.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call UserS3KeysApi.um_users_s3keys_get' do
      s3_keys = s3_keys_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        user_id: 'user_id',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      s3_key_list = [
        subject.ui.color('ID', :bold),
        subject.ui.color('Secret Key', :bold),
        subject.ui.color('Active', :bold),
        s3_keys.items.first.id,
        s3_keys.items.first.properties.secret_key,
        s3_keys.items.first.properties.active.to_s,
      ]

      expect(subject.ui).to receive(:list).with(s3_key_list, :uneven_columns_across, 3)

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/um/users/#{subject_config[:user_id]}/s3keys",
            operation: :'UserS3KeysApi.um_users_s3keys_get',
            return_type: 'S3Keys',
            result: s3_keys,
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
