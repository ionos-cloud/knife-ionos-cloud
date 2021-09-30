require 'spec_helper'
require 'ionoscloud_share_list'

Chef::Knife::IonoscloudShareList.load_deps

describe Chef::Knife::IonoscloudShareList do
  before :each do
    subject { Chef::Knife::IonoscloudShareList.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call UserManagementApi.um_groups_shares_get' do
      shares = group_shares_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        group_id: 'group_id',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      share_list = [
        subject.ui.color('ID', :bold),
        subject.ui.color('Edit Privilege', :bold),
        subject.ui.color('Share Privilege', :bold),
        shares.items.first.id,
        shares.items.first.properties.edit_privilege.to_s,
        shares.items.first.properties.share_privilege.to_s,
      ]

      expect(subject.ui).to receive(:list).with(share_list, :uneven_columns_across, 3)

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/um/groups/#{subject_config[:group_id]}/shares",
            operation: :'UserManagementApi.um_groups_shares_get',
            return_type: 'GroupShares',
            result: shares,
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
