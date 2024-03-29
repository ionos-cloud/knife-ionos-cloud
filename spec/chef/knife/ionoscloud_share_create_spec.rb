require 'spec_helper'
require 'ionoscloud_share_create'

Chef::Knife::IonoscloudShareCreate.load_deps

describe Chef::Knife::IonoscloudShareCreate do
  before :each do
    subject { Chef::Knife::IonoscloudShareCreate.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call UserManagementApi.um_groups_shares_post with the expected arguments and output based on what it receives' do
      share = group_share_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        group_id: 'group_id',
        resource_id: 'resource_id',
        edit_privilege: share.properties.edit_privilege,
        share_privilege: share.properties.share_privilege,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{share.id}")
      expect(subject).to receive(:puts).with("Edit Privilege: #{share.properties.edit_privilege.to_s}")
      expect(subject).to receive(:puts).with("Share Privilege: #{share.properties.share_privilege.to_s}")

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'POST',
            path: "/um/groups/#{subject_config[:group_id]}/shares/#{subject_config[:resource_id]}",
            operation: :'UserManagementApi.um_groups_shares_post',
            return_type: 'GroupShare',
            body: { properties: share.properties.to_hash },
            result: share,
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
