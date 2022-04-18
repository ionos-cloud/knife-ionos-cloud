require 'spec_helper'
require 'ionoscloud_autoscaling_action_get'

Chef::Knife::IonoscloudVmAutoscalingActionGet.load_deps

describe Chef::Knife::IonoscloudVmAutoscalingActionGet do
  before :each do
    subject { Chef::Knife::IonoscloudVmAutoscalingActionGet.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call AutoscalingApi.autoscaling_groups_actions_find_by_id' do
      autoscaling_action = vm_autoscaling_action_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        group_id: 'group_id',
        action_id: autoscaling_action.id,
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{autoscaling_action.id}")
      expect(subject).to receive(:puts).with("Type: #{autoscaling_action.type}")
      expect(subject).to receive(:puts).with("Action Status: #{autoscaling_action.properties.action_status}")
      expect(subject).to receive(:puts).with("Action Type: #{autoscaling_action.properties.action_type}")
      expect(subject).to receive(:puts).with("Target Replica Count: #{autoscaling_action.properties.target_replica_count}")

      mock_vm_autoscaling_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/cloudapi/autoscaling/groups/#{subject_config[:group_id]}/actions/#{subject_config[:action_id]}",
            operation: :'GroupsApi.autoscaling_groups_actions_find_by_id',
            return_type: 'Action',
            result: autoscaling_action,
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