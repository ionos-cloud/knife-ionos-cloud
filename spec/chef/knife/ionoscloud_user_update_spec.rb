require 'spec_helper'
require 'ionoscloud_user_update'

Chef::Knife::IonoscloudUserUpdate.load_deps

describe Chef::Knife::IonoscloudUserUpdate do
  before :each do
    subject { Chef::Knife::IonoscloudUserUpdate.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call UserManagementApi.um_groups_users_put' do
      user = user_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        user_id: user.id,
        firstname: user.properties.firstname + '_edited',
        lastname: user.properties.lastname + '_edited',
        email: user.properties.email + '_edited',
        administrator: (!user.properties.administrator).to_s,
        force_sec_auth: (!user.properties.force_sec_auth).to_s,
        sec_auth_active: (!user.properties.sec_auth_active).to_s,
        active: (!user.properties.active).to_s,
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{user.id}")
      expect(subject).to receive(:puts).with("Firstname: #{subject_config[:firstname]}")
      expect(subject).to receive(:puts).with("Lastname: #{subject_config[:lastname]}")
      expect(subject).to receive(:puts).with("Email: #{subject_config[:email]}")
      expect(subject).to receive(:puts).with("Administrator: #{subject_config[:administrator]}")
      expect(subject).to receive(:puts).with("Force 2-Factor Auth: #{subject_config[:force_sec_auth]}")
      expect(subject).to receive(:puts).with("2-Factor Auth Active: #{subject_config[:sec_auth_active]}")
      expect(subject).to receive(:puts).with("Active: #{subject_config[:active]}")

      user.properties.firstname = subject_config[:firstname]
      user.properties.lastname = subject_config[:lastname]
      user.properties.email = subject_config[:email]
      user.properties.administrator = subject_config[:administrator].to_s.downcase == 'true'
      user.properties.force_sec_auth = subject_config[:force_sec_auth].to_s.downcase == 'true'
      user.properties.sec_auth_active = subject_config[:sec_auth_active].to_s.downcase == 'true'
      user.properties.active = subject_config[:active].to_s.downcase == 'true'

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/um/users/#{subject_config[:user_id]}",
            operation: :'UserManagementApi.um_users_find_by_id',
            return_type: 'User',
            result: user,
          },
          {
            method: 'PUT',
            path: "/um/users/#{subject_config[:user_id]}",
            operation: :'UserManagementApi.um_users_put',
            return_type: 'User',
            body: {
                properties: {
                  firstname: subject_config[:firstname],
                  lastname: subject_config[:lastname],
                  email: subject_config[:email],
                  administrator: subject_config[:administrator].to_s.downcase == 'true',
                  forceSecAuth: subject_config[:force_sec_auth].to_s.downcase == 'true',
                  secAuthActive: subject_config[:sec_auth_active].to_s.downcase == 'true',
                  active: subject_config[:active].to_s.downcase == 'true',
              },
            },
            result: user,
          },
          {
            method: 'GET',
            path: "/um/users/#{subject_config[:user_id]}",
            operation: :'UserManagementApi.um_users_find_by_id',
            return_type: 'User',
            result: user,
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
