require 'spec_helper'
require 'ionoscloud_autoscaling_group_delete'

Chef::Knife::IonoscloudVmAutoscalingGroupCDelete.load_deps

describe Chef::Knife::IonoscloudVmAutoscalingGroupCDelete do
  before :each do
    subject { Chef::Knife::IonoscloudVmAutoscalingGroupCDelete.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call GroupsApi.autoscaling_groups_delete when the ID is valid' do
      autoscaling_group = vm_autoscaling_group_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [autoscaling_group.id]

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
      expect(subject.ui).to receive(:warn).with("Deleted VM Autoscaling Group #{autoscaling_group.id}. Request ID: ")
      
      mock_vm_autoscaling_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/cloudapi/autoscaling/groups/#{autoscaling_group.id}",
            operation: :'GroupsApi.autoscaling_groups_find_by_id',
            return_type: 'Group',
            result: autoscaling_group,
          },
          {
            method: 'DELETE',
            path: "/cloudapi/autoscaling/groups/#{autoscaling_group.id}",
            operation: :'GroupsApi.autoscaling_groups_delete',
            return_type: nil,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not call GroupsApi.autoscaling_groups_delete when the user ID is not valid' do
      group_id = 'invalid_id'
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [group_id]

      expect(subject.ui).to receive(:error).with("VM Autoscaling Group ID #{group_id} not found. Skipping.")

      mock_vm_autoscaling_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/cloudapi/autoscaling/groups/#{group_id}",
            operation: :'GroupsApi.autoscaling_groups_find_by_id',
            return_type: 'Group',
            exception: IonoscloudVmAutoscaling::ApiError.new(code: 404),
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