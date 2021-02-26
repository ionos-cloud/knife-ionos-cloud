require 'spec_helper'
require 'ionoscloud_s3key_list'

Chef::Knife::IonoscloudS3keyList.load_deps

describe Chef::Knife::IonoscloudS3keyList do
  subject { Chef::Knife::IonoscloudS3keyList.new }

  describe '#run' do
    it 'should call UserManagementApi.um_users_s3keys_get' do
    s3_keys = s3_keys_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        user_id: 'user_id',
      }
 
      subject_config.each { |key, value| subject.config[key] = value }

      allow(subject).to receive(:puts)
      allow(subject).to receive(:print)
      allow(subject.ui).to receive(:list)

      user_list = user_list = [
        subject.ui.color('ID', :bold),
        subject.ui.color('Secret Key', :bold),
        subject.ui.color('Active', :bold),
        s3_keys.items.first.id,
        s3_keys.items.first.properties.secret_key,
        s3_keys.items.first.properties.active.to_s,
      ]

      expect(subject.ui).to receive(:list).with(user_list, :uneven_columns_across, 3)

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/um/users/#{subject_config[:user_id]}/s3keys",
            operation: :'UserManagementApi.um_users_s3keys_get',
            return_type: 'S3Keys',
            result: s3_keys,
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
