require 'spec_helper'
require 'ionoscloud_autoscaling_action_get'

Chef::Knife::IonoscloudAutoscalingActionGet.load_deps

describe Chef::Knife::IonoscloudAutoscalingActionGet do
  before :each do
    subject { Chef::Knife::IonoscloudAutoscalingActionGet.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call AutoscailingApi.autoscaling_groups_actions_find_by_id' do
      autoscailing_action = vm_autoscailing_action_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        group_id: 'group_id',
        action_id: autoscailing_action.id,
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{autoscailing_action.id}")
      expect(subject).to receive(:puts).with("TYPE: #{autoscailing_action.type}")
      expect(subject).to receive(:puts).with("ACTION STATUS: #{autoscailing_action.properties.action_status}")
      expect(subject).to receive(:puts).with("ACTION TYPE: #{autoscailing_action.properties.action_type}")
      expect(subject).to receive(:puts).with("TARGET REPLICA COUNT: #{autoscailing_action.properties.target_replica_count}")

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/cloudapi/autoscaling/groups/#{subject_config[:group_id]}/actions/#{subject_config[:action_id]}",
            operation: :'GroupsApi.autoscaling_groups_actions_find_by_id',
            return_type: 'Action',
            result: autoscailing_action,
          },
        ],
      )

      # expect { subject.run }.not_to raise_error(Exception)
      subject.run
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