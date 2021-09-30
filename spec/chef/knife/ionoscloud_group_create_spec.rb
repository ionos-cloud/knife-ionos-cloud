require 'spec_helper'
require 'ionoscloud_group_create'

Chef::Knife::IonoscloudGroupCreate.load_deps

describe Chef::Knife::IonoscloudGroupCreate do
  before :each do
    subject { Chef::Knife::IonoscloudGroupCreate.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call UserManagementApi.um_groups_post with the expected arguments and output based on what it receives' do
      group = group_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        name: group.properties.name,
        create_data_center: group.properties.create_data_center,
        create_snapshot: group.properties.create_snapshot,
        reserve_ip: group.properties.reserve_ip,
        access_activity_log: group.properties.access_activity_log,
        s3_privilege: group.properties.s3_privilege,
        create_backup_unit: group.properties.create_backup_unit,
        create_k8s_cluster: group.properties.create_k8s_cluster,
        create_pcc: group.properties.create_pcc,
        create_internet_access: group.properties.create_internet_access,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      check_group_print(subject, group)

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'POST',
            path: '/um/groups',
            operation: :'UserManagementApi.um_groups_post',
            return_type: 'Group',
            body: { properties: group.properties.to_hash },
            result: group,
          },
          {
            method: 'GET',
            path: "/um/groups/#{group.id}",
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
