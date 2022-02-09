require 'spec_helper'
require 'ionoscloud_group_list'

Chef::Knife::IonoscloudGroupList.load_deps

describe Chef::Knife::IonoscloudGroupList do
  before :each do
    subject { Chef::Knife::IonoscloudGroupList.new }

    @groups = groups_mock
    @group_list = group_list = [
      subject.ui.color('ID', :bold),
      subject.ui.color('Name', :bold),
      subject.ui.color('Datacenter', :bold),
      subject.ui.color('Snapshot', :bold),
      subject.ui.color('IP', :bold),
      subject.ui.color('Activity', :bold),
      subject.ui.color('S3', :bold),
      subject.ui.color('Backup', :bold),
      subject.ui.color('K8s', :bold),
      subject.ui.color('PCC', :bold),
      subject.ui.color('Internet', :bold),
      subject.ui.color('FlowLogs', :bold),
      subject.ui.color('Monitoring', :bold),
      subject.ui.color('Certificates', :bold),
      @groups.items.first.id,
      @groups.items.first.properties.name,
      @groups.items.first.properties.create_data_center.to_s,
      @groups.items.first.properties.create_snapshot.to_s,
      @groups.items.first.properties.reserve_ip.to_s,
      @groups.items.first.properties.access_activity_log.to_s,
      @groups.items.first.properties.s3_privilege.to_s,
      @groups.items.first.properties.create_backup_unit.to_s,
      @groups.items.first.properties.create_k8s_cluster.to_s,
      @groups.items.first.properties.create_pcc.to_s,
      @groups.items.first.properties.create_internet_access.to_s,
      @groups.items.first.properties.create_flow_log.to_s,
      @groups.items.first.properties.access_and_manage_monitoring.to_s,
      @groups.items.first.properties.access_and_manage_certificates.to_s,
      @groups.items[1].id,
      @groups.items[1].properties.name,
      @groups.items[1].properties.create_data_center.to_s,
      @groups.items[1].properties.create_snapshot.to_s,
      @groups.items[1].properties.reserve_ip.to_s,
      @groups.items[1].properties.access_activity_log.to_s,
      @groups.items[1].properties.s3_privilege.to_s,
      @groups.items[1].properties.create_backup_unit.to_s,
      @groups.items[1].properties.create_k8s_cluster.to_s,
      @groups.items[1].properties.create_pcc.to_s,
      @groups.items[1].properties.create_internet_access.to_s,
      @groups.items[1].properties.create_flow_log.to_s,
      @groups.items[1].properties.access_and_manage_monitoring.to_s,
      @groups.items[1].properties.access_and_manage_certificates.to_s,
    ]

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call UserManagementApi.um_groups_get when no user_id is set' do
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject.ui).to receive(:list).with(@group_list, :uneven_columns_across, 14)

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: '/um/groups',
            operation: :'UserManagementApi.um_groups_get',
            return_type: 'Groups',
            result: @groups,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should call UserManagementApi.um_groups_groups_get when user_id is set' do
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        user_id: 'user_id'
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject.ui).to receive(:list).with(@group_list, :uneven_columns_across, 14)

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/um/users/#{subject_config[:user_id]}/groups",
            operation: :'UserManagementApi.um_users_groups_get',
            return_type: 'ResourceGroups',
            result: @groups,
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
