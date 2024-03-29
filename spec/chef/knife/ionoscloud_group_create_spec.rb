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
        create_flow_log: group.properties.create_flow_log,
        access_and_manage_monitoring: group.properties.access_and_manage_monitoring,
        access_and_manage_certificates: group.properties.access_and_manage_certificates,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      users = group.entities.users.items.map { |el| el.id }

      expect(subject).to receive(:puts).with("ID: #{group.id}")
      expect(subject).to receive(:puts).with("Name: #{group.properties.name}")
      expect(subject).to receive(:puts).with("Create Datacenter: #{group.properties.create_data_center.to_s}")
      expect(subject).to receive(:puts).with("Create Snapshot: #{group.properties.create_snapshot.to_s}")
      expect(subject).to receive(:puts).with("Reserve IP: #{group.properties.reserve_ip.to_s}")
      expect(subject).to receive(:puts).with("Access Activity Log: #{group.properties.access_activity_log.to_s}")
      expect(subject).to receive(:puts).with("S3 Privilege: #{group.properties.s3_privilege.to_s}")
      expect(subject).to receive(:puts).with("Create Backup Unit: #{group.properties.create_backup_unit.to_s}")
      expect(subject).to receive(:puts).with("Create K8s Clusters: #{group.properties.create_k8s_cluster.to_s}")
      expect(subject).to receive(:puts).with("Create PCC: #{group.properties.create_pcc.to_s}")
      expect(subject).to receive(:puts).with("Create Internet Acess: #{group.properties.create_internet_access.to_s}")
      expect(subject).to receive(:puts).with("Create Flow Logs: #{group.properties.create_flow_log.to_s}")
      expect(subject).to receive(:puts).with("Access and Manage Monitoring: #{group.properties.access_and_manage_monitoring.to_s}")
      expect(subject).to receive(:puts).with("Access and Manage Certificates: #{group.properties.access_and_manage_certificates.to_s}")
      expect(subject).to receive(:puts).with("Users: #{users.to_s}")

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
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not make any call if any required option is missing' do
      required_options = subject.instance_variable_get(:@required_options)

      if required_options.length > 0
        arrays_without_one_element(required_options).each do |test_case|
          subject.config[:ionoscloud_token] = 'token'
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
end
