require 'spec_helper'
require 'ionoscloud_share_update'

Chef::Knife::IonoscloudShareUpdate.load_deps

describe Chef::Knife::IonoscloudShareUpdate do
  before :each do
    subject { Chef::Knife::IonoscloudShareUpdate.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call UserManagementApi.um_groups_shares_patch' do
      share = group_share_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        group_id: 'group_id',
        resource_id: share.id,
        share_privilege: (!share.properties.share_privilege).to_s,
        edit_privilege: (!share.properties.edit_privilege).to_s,
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{share.id}")
      expect(subject).to receive(:puts).with("Edit Privilege: #{subject_config[:edit_privilege]}")
      expect(subject).to receive(:puts).with("Share Privilege: #{subject_config[:share_privilege]}")

      share.properties.edit_privilege = subject_config[:edit_privilege].to_s.downcase == 'true'
      share.properties.share_privilege = subject_config[:share_privilege].to_s.downcase == 'true'

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/um/groups/#{subject_config[:group_id]}/shares/#{subject_config[:resource_id]}",
            operation: :'UserManagementApi.um_groups_shares_find_by_resource_id',
            return_type: 'GroupShare',
            result: share,
          },
          {
            method: 'PUT',
            path: "/um/groups/#{subject_config[:group_id]}/shares/#{subject_config[:resource_id]}",
            operation: :'UserManagementApi.um_groups_shares_put',
            return_type: 'GroupShare',
            body: {
                properties: {
                  editPrivilege: subject_config[:edit_privilege].to_s.downcase == 'true',
                  sharePrivilege: subject_config[:share_privilege].to_s.downcase == 'true',
              },
            },
            result: share,
          },
          {
            method: 'GET',
            path: "/um/groups/#{subject_config[:group_id]}/shares/#{subject_config[:resource_id]}",
            operation: :'UserManagementApi.um_groups_shares_find_by_resource_id',
            return_type: 'GroupShare',
            result: share,
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
