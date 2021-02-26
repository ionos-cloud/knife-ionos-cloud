require 'spec_helper'
require 'ionoscloud_share_list'

Chef::Knife::IonoscloudShareList.load_deps

describe Chef::Knife::IonoscloudShareList do
  subject { Chef::Knife::IonoscloudShareList.new }

  describe '#run' do
    it 'should call UserManagementApi.um_groups_shares_get' do
    shares = group_shares_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        group_id: 'group_id',
      }
 
      subject_config.each { |key, value| subject.config[key] = value }

      allow(subject).to receive(:puts)
      allow(subject).to receive(:print)
      allow(subject.ui).to receive(:list)

      user_list = user_list = [
        subject.ui.color('ID', :bold),
        subject.ui.color('Edit Privilege', :bold),
        subject.ui.color('Share Privilege', :bold),
        shares.items.first.id,
        shares.items.first.properties.edit_privilege.to_s,
        shares.items.first.properties.share_privilege.to_s,
      ]

      expect(subject.ui).to receive(:list).with(user_list, :uneven_columns_across, 3)

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
