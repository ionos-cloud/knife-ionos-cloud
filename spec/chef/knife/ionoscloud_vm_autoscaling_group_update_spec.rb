require 'spec_helper'
require 'ionoscloud_vm_autoscaling_group_update'

Chef::Knife::IonoscloudVmAutoscalingGroupUpdate.load_deps

describe Chef::Knife::IonoscloudVmAutoscalingGroupUpdate do
  before :each do
    subject { Chef::Knife::IonoscloudVmAutoscalingGroupUpdate.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call GroupsApi.autoscaling_groups_put' do
      autoscaling_group = vm_autoscaling_group_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        group_id: autoscaling_group.id,
        name: autoscaling_group.properties.name + '_edited',
        target_replica_count: autoscaling_group.properties.target_replica_count + 1,
        max_replica_count: autoscaling_group.properties.max_replica_count + 1,
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{autoscaling_group.id}")
      expect(subject).to receive(:puts).with("Min Replica Count: #{autoscaling_group.properties.min_replica_count}")
      expect(subject).to receive(:puts).with("Max Replica Count: #{subject_config[:max_replica_count]}")
      expect(subject).to receive(:puts).with("Target Replica Count: #{subject_config[:target_replica_count]}")
      expect(subject).to receive(:puts).with("Name: #{subject_config[:name]}")
      expect(subject).to receive(:puts).with("Policy: #{autoscaling_group.properties.policy}")
      expect(subject).to receive(:puts).with("Replica Configuration: #{autoscaling_group.properties.replica_configuration}")
      expect(subject).to receive(:puts).with("Datacenter ID: #{autoscaling_group.properties.datacenter.id}")
      expect(subject).to receive(:puts).with("Location: #{autoscaling_group.properties.location}")

      expected_body = autoscaling_group.properties.to_hash

      expected_body.delete(:location)
      expected_body[:replicaConfiguration].delete(:volumes)
      expected_body[:name] = subject_config[:name]
      expected_body[:targetReplicaCount] = subject_config[:target_replica_count]
      expected_body[:maxReplicaCount] = subject_config[:max_replica_count]

      autoscaling_group.properties.name = subject_config[:name]
      autoscaling_group.properties.max_replica_count = subject_config[:max_replica_count]
      autoscaling_group.properties.target_replica_count = subject_config[:target_replica_count]

      mock_vm_autoscaling_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/cloudapi/autoscaling/groups/#{subject_config[:group_id]}",
            operation: :'GroupsApi.autoscaling_groups_find_by_id',
            return_type: 'Group',
            result: autoscaling_group,
          },
          {
            method: 'PUT',
            path: "/cloudapi/autoscaling/groups/#{autoscaling_group.id}",
            operation: :'GroupsApi.autoscaling_groups_put',
            return_type: 'Group',
            body: { properties: expected_body },
            result: autoscaling_group,
          },
          {
            method: 'GET',
            path: "/cloudapi/autoscaling/groups/#{autoscaling_group.id}",
            operation: :'GroupsApi.autoscaling_groups_find_by_id',
            return_type: 'Group',
            result: autoscaling_group,
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
        expect(subject.api_client_vm_autoscaling).not_to receive(:call_api)

        expect { subject.run }.to raise_error(SystemExit) do |error|
          expect(error.status).to eq(1)
        end

        required_options.each { |value| subject.config[value] = nil }
      end
    end
  end
end
