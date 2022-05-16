require 'spec_helper'
require 'ionoscloud_share_delete'

Chef::Knife::IonoscloudShareDelete.load_deps

describe Chef::Knife::IonoscloudShareDelete do
  before :each do
    subject { Chef::Knife::IonoscloudShareDelete.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call UserManagementApi.um_groups_shares_delete when the ID is valid' do
      share = group_share_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        group_id: 'group_id',
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [share.id]

      expect(subject).to receive(:puts).with("ID: #{share.id}")
      expect(subject).to receive(:puts).with("Edit Privilege: #{share.properties.edit_privilege.to_s}")
      expect(subject).to receive(:puts).with("Share Privilege: #{share.properties.share_privilege.to_s}")
      expect(subject.ui).to receive(:warn).with("Deleted Resource Share #{share.id}. Request ID: ")

      expect(subject.api_client).not_to receive(:wait_for)
      expect(subject).to receive(:get_request_id).once
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/um/groups/#{subject_config[:group_id]}/shares/#{share.id}",
            operation: :'UserManagementApi.um_groups_shares_find_by_resource_id',
            return_type: 'GroupShare',
            result: share,
          },
          {
            method: 'DELETE',
            path: "/um/groups/#{subject_config[:group_id]}/shares/#{share.id}",
            operation: :'UserManagementApi.um_groups_shares_delete',
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not call UserManagementApi.um_groups_shares_delete when the ID is not valid' do
      share_id = 'invalid_id'
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        group_id: 'group_id',
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [share_id]

      expect(subject.ui).to receive(:error).with("Resource Share ID #{share_id} not found. Skipping.")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/um/groups/#{subject_config[:group_id]}/shares/#{share_id}",
            operation: :'UserManagementApi.um_groups_shares_find_by_resource_id',
            return_type: 'GroupShare',
            exception: Ionoscloud::ApiError.new(code: 404),
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
