require 'spec_helper'
require 'ionoscloud_user_list'

Chef::Knife::IonoscloudUserList.load_deps

describe Chef::Knife::IonoscloudUserList do
  before :each do
    subject { Chef::Knife::IonoscloudUserList.new }

    @users = users_mock
    @user_list = [
      subject.ui.color('ID', :bold),
      subject.ui.color('Firstname', :bold),
      subject.ui.color('Lastname', :bold),
      subject.ui.color('Email', :bold),
      subject.ui.color('Administrator', :bold),
      subject.ui.color('2-Factor Auth', :bold),
      @users.items.first.id,
      @users.items.first.properties.firstname,
      @users.items.first.properties.lastname,
      @users.items.first.properties.email,
      @users.items.first.properties.administrator.to_s,
      @users.items.first.properties.force_sec_auth.to_s,
    ]

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call UserManagementApi.um_users_get when no group_id is set' do
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject.ui).to receive(:list).with(@user_list, :uneven_columns_across, 6)

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: '/um/users',
            operation: :'UserManagementApi.um_users_get',
            return_type: 'Users',
            result: @users,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should call UserManagementApi.um_groups_users_get when group_id is set' do
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        group_id: 'group_id',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject.ui).to receive(:list).with(@user_list, :uneven_columns_across, 6)

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/um/groups/#{subject_config[:group_id]}/users",
            operation: :'UserManagementApi.um_groups_users_get',
            return_type: 'GroupMembers',
            result: @users,
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
