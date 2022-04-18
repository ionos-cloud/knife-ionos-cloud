require 'spec_helper'
require 'ionoscloud_autoscaling_group_create'

Chef::Knife::IonoscloudVmAutoscalingGroupCreate.load_deps

describe Chef::Knife::IonoscloudVmAutoscalingGroupCreate do
  before :each do
    subject { Chef::Knife::IonoscloudVmAutoscalingGroupCreate.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call GroupsApi.autoscaling_groups_post with the expected arguments and output based on what it receives' do
      autoscaling_group = vm_autoscaling_group_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        group_id: 'group_id',
        max_replica_count: autoscaling_group.properties.max_replica_count,
        min_replica_count: autoscaling_group.properties.min_replica_count,
        target_replica_count: autoscaling_group.properties.target_replica_count,
        name: autoscaling_group.properties.name,
        policy: autoscaling_group.properties.policy,
        replica_configuration: autoscaling_group.properties.replica_configuration,
        resource_id: autoscaling_group.properties.datacenter.id,
        resource_type: autoscaling_group.properties.datacenter.type,
        location: autoscaling_group.properties.location,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{autoscaling_group.id}")
      expect(subject).to receive(:puts).with("Max Replica Count: #{autoscaling_group.properties.max_replica_count}")
      expect(subject).to receive(:puts).with("Min Replica Count: #{autoscaling_group.properties.min_replica_count}")
      expect(subject).to receive(:puts).with("Target Replica Count: #{autoscaling_group.properties.target_replica_count}")
      expect(subject).to receive(:puts).with("Name: #{autoscaling_group.properties.name}")
      expect(subject).to receive(:puts).with("Policy: #{autoscaling_group.properties.policy}")
      expect(subject).to receive(:puts).with("Replica Configuration: #{autoscaling_group.properties.replica_configuration}")
      expect(subject).to receive(:puts).with("Datacenter: Datacenter ID: #{autoscaling_group.properties.datacenter.id}, Type: #{autoscaling_group.properties.datacenter.type}")
      expect(subject).to receive(:puts).with("Location: #{autoscaling_group.properties.location}")

      expected_body = autoscaling_group.properties.to_hash

      mock_vm_autoscaling_call_api(
        subject,
        [
          {
            method: 'POST',
            path: '/cloudapi/autoscaling/groups',
            operation: :'GroupsApi.autoscaling_groups_post',
            return_type: 'GroupPostResponse',
            body: { properties: expected_body },
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
