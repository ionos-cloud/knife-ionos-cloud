require 'spec_helper'
require 'ionoscloud_autoscaling_group_get'

Chef::Knife::IonoscloudVmAutoscalingGroupGet.load_deps

describe Chef::Knife::IonoscloudVmAutoscalingGroupGet do
  before :each do
    subject { Chef::Knife::IonoscloudVmAutoscalingGroupGet.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call AutoscalingApi.autoscaling_groups_actions_find_by_id' do
      autoscaling_group = vm_autoscaling_group_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        group_id: autoscaling_group.id,
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{autoscaling_group.id}")
      expect(subject).to receive(:puts).with("Type: #{autoscaling_group.type}")
      expect(subject).to receive(:puts).with("Max Replica Count: #{autoscaling_group.properties.max_replica_count}")
      expect(subject).to receive(:puts).with("Min Replica Count: #{autoscaling_group.properties.min_replica_count}")
      expect(subject).to receive(:puts).with("Target Replica Count: #{autoscaling_group.properties.target_replica_count}")
      expect(subject).to receive(:puts).with("Name: #{autoscaling_group.properties.name}")
      expect(subject).to receive(:puts).with("Policy: #{autoscaling_group.properties.policy}")
      expect(subject).to receive(:puts).with("Replica Configuration: #{autoscaling_group.properties.replica_configuration}")
      expect(subject).to receive(:puts).with("Datacenter: Datacenter ID: #{autoscaling_group.properties.datacenter.id}, Type: #{autoscaling_group.properties.datacenter.type}")
      expect(subject).to receive(:puts).with("Location: #{autoscaling_group.properties.location}")

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
