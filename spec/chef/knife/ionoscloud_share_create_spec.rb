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
      check_required_options(subject)
    end
  end
end
