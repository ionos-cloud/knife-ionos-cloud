require 'spec_helper'
require 'ionoscloud_autoscailing_group_delete'

Chef::Knife::IonoscloudAutoscailingGroupCDelete.load_deps

describe Chef::Knife::IonoscloudAutoscailingGroupCDelete do
  before :each do
    subject { Chef::Knife::IonoscloudAutoscailingGroupCDelete.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call ClustersApi.clusters_delete when the ID is valid' do
      autoscailing_group = vm_autoscailing_group_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [autoscailing_group.id]

      expect(subject).to receive(:puts).with("ID: #{autoscailing_group.id}")
      expect(subject).to receive(:puts).with("TYPE: #{autoscailing_group.type}")
      expect(subject).to receive(:puts).with("ACTION STATUS: #{autoscailing_group.properties.action_status}")
      expect(subject).to receive(:puts).with("ACTION TYPE: #{autoscailing_group.properties.action_type}")
      expect(subject).to receive(:puts).with("TARGET REPLICA COUNT: #{autoscailing_group.properties.target_replica_count}")
      
      mock_dbaas_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/autoscaling/groups/#{autoscailing_group.id}",
            operation: :'GroupsApi.autoscaling_groups_find_by_id',
            return_type: 'Group',
            result: autoscailing_group,
          },
          {
            method: 'DELETE',
            path: "/autoscaling/groups/#{autoscailing_group.id}",
            operation: :'GroupsApi.autoscaling_groups_delete',
            return_type: nil,
            body: {},
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not call ClustersApi.clusters_delete when the user ID is not valid' do
      group_id = 'invalid_id'
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [group_id]

      expect(subject.ui).to receive(:error).with("Cluster ID #{group_id} not found. Skipping.")

      mock_dbaas_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/autoscaling/groups/#{autoscailing_group.id}",
            operation: :'GroupsApi.autoscaling_groups_find_by_id',
            return_type: 'Group',
            exception: IonoscloudAutoscaling::ApiError.new(code: 404),
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