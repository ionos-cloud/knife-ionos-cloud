require 'spec_helper'
require 'ionoscloud_group_delete'

Chef::Knife::IonoscloudGroupDelete.load_deps

describe Chef::Knife::IonoscloudGroupDelete do
  before :each do
    subject { Chef::Knife::IonoscloudGroupDelete.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call UserManagementApi.um_groups_delete when the ID is valid' do
      group = group_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [group.id]

      check_group_print(subject, group)
      expect(subject.ui).to receive(:warn).with("Deleted Group #{group.id}. Request ID: ")

      expect(subject.api_client).not_to receive(:wait_for)
      expect(subject).to receive(:get_request_id).once
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/um/groups/#{group.id}",
            operation: :'UserManagementApi.um_groups_find_by_id',
            return_type: 'Group',
            result: group,
          },
          {
            method: 'DELETE',
            path: "/um/groups/#{group.id}",
            operation: :'UserManagementApi.um_groups_delete',
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not call UserManagementApi.um_groups_delete when the ID is not valid' do
      group_id = 'invalid_id'
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [group_id]

      expect(subject.ui).to receive(:error).with("Group ID #{group_id} not found. Skipping.")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/um/groups/#{group_id}",
            operation: :'UserManagementApi.um_groups_find_by_id',
            return_type: 'Group',
            exception: Ionoscloud::ApiError.new(code: 404),
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
