require 'spec_helper'
require 'ionoscloud_group_update'

Chef::Knife::IonoscloudGroupUpdate.load_deps

describe Chef::Knife::IonoscloudGroupUpdate do
  before :each do
    subject { Chef::Knife::IonoscloudGroupUpdate.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call UserManagementApi.um_groups_put' do
      group = group_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        group_id: group.id,
        name: group.properties.name + '_edited',
        create_snapshot: !group.properties.create_snapshot,
        reserve_ip: group.properties.reserve_ip,
        access_activity_log: !group.properties.access_activity_log,
        create_backup_unit: !group.properties.create_backup_unit,
        create_pcc: !group.properties.create_pcc,
        create_flow_log: !group.properties.create_flow_log,
        access_and_manage_monitoring: !group.properties.access_and_manage_monitoring,
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      users = group.entities.users.items.map { |el| el.id }

      expect(subject).to receive(:puts).with("ID: #{group.id}")
      expect(subject).to receive(:puts).with("Name: #{subject_config[:name]}")
      expect(subject).to receive(:puts).with("Create Datacenter: #{group.properties.create_data_center.to_s}")
      expect(subject).to receive(:puts).with("Create Snapshot: #{subject_config[:create_snapshot]}")
      expect(subject).to receive(:puts).with("Reserve IP: #{group.properties.reserve_ip.to_s}")
      expect(subject).to receive(:puts).with("Access Activity Log: #{subject_config[:access_activity_log]}")
      expect(subject).to receive(:puts).with("S3 Privilege: #{group.properties.s3_privilege.to_s}")
      expect(subject).to receive(:puts).with("Create Backup Unit: #{subject_config[:create_backup_unit]}")
      expect(subject).to receive(:puts).with("Create K8s Clusters: #{group.properties.create_k8s_cluster.to_s}")
      expect(subject).to receive(:puts).with("Create PCC: #{subject_config[:create_pcc]}")
      expect(subject).to receive(:puts).with("Create Internet Acess: #{group.properties.create_internet_access.to_s}")
      expect(subject).to receive(:puts).with("Create Flow Logs: #{subject_config[:create_flow_log]}")
      expect(subject).to receive(:puts).with("Access and Manage Monitoring: #{subject_config[:access_and_manage_monitoring]}")
      expect(subject).to receive(:puts).with("Access and Manage Certificates: #{group.properties.access_and_manage_certificates.to_s}")
      expect(subject).to receive(:puts).with("Users: #{users.to_s}")

      expected_body = group.properties.to_hash.merge({
        name: subject_config[:name],
        createSnapshot: subject_config[:create_snapshot],
        reserveIp: subject_config[:reserve_ip],
        accessActivityLog: subject_config[:access_activity_log],
        createBackupUnit: subject_config[:create_backup_unit],
        createPcc: subject_config[:create_pcc],
        createFlowLog: subject_config[:create_flow_log],
        accessAndManageMonitoring: subject_config[:access_and_manage_monitoring],
      })

      group.properties.name = subject_config[:name]
      group.properties.create_snapshot = subject_config[:create_snapshot]
      group.properties.access_activity_log = subject_config[:access_activity_log]
      group.properties.create_backup_unit = subject_config[:create_backup_unit]
      group.properties.create_pcc = subject_config[:create_pcc]
      group.properties.create_flow_log = subject_config[:create_flow_log]
      group.properties.access_and_manage_monitoring = subject_config[:access_and_manage_monitoring]

      mock_wait_for(subject)
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
            method: 'PUT',
            path: "/um/groups/#{group.id}",
            operation: :'UserManagementApi.um_groups_put',
            return_type: 'Group',
            body: { properties: expected_body },
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
