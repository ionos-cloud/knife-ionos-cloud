require 'spec_helper'
require 'ionoscloud_group_get'

Chef::Knife::IonoscloudGroupGet.load_deps

describe Chef::Knife::IonoscloudGroupGet do
  before :each do
    subject { Chef::Knife::IonoscloudGroupGet.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call UserManagementApi.um_groups_find_by_id' do
      group = group_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        group_id: group.id,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      check_group_print(subject, group)

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/um/groups/#{subject_config[:group_id]}",
            operation: :'UserManagementApi.um_groups_find_by_id',
            return_type: 'Group',
            result: group,
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
