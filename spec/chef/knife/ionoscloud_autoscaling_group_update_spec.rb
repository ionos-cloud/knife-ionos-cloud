require 'spec_helper'
require 'ionoscloud_autoscaling_group_update'

Chef::Knife::IonoscloudAutoscalingGroupUpdate.load_deps

describe Chef::Knife::IonoscloudAutoscalingGroupUpdate do
  before :each do
    subject { Chef::Knife::IonoscloudAutoscalingGroupUpdate.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call ClustersApi.clusters_patch' do
      autoscailing_group = vm_autoscailing_group_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        group_id: autoscailing_group.id,
        name: autoscailing_group.properties.name + '_edited',
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{autoscailing_group.id}")
      expect(subject).to receive(:puts).with("TYPE: #{autoscailing_group.type}")
      expect(subject).to receive(:puts).with("MAX REPLICA COUNT: #{autoscailing_group.properties.max_replica_count}")
      expect(subject).to receive(:puts).with("MIN REPLICA COUNT: #{autoscailing_group.properties.min_replica_count}")
      expect(subject).to receive(:puts).with("TARGET REPLICA COUNT: #{autoscailing_group.properties.target_replica_count}")
      expect(subject).to receive(:puts).with("Display Name: #{subject_config[:name]}")
      expect(subject).to receive(:puts).with("POLICY: #{autoscailing_group.properties.policy}")
      expect(subject).to receive(:puts).with("REPLICA CONFIGURATION: #{autoscailing_group.properties.replica_configuration}")
      expect(subject).to receive(:puts).with("DATACENTER: #{autoscailing_group.properties.datacenter}")
      expect(subject).to receive(:puts).with("LOCATION: #{autoscailing_group.properties.location}")

      expected_body = {
        displayName: subject_config[:name],
      }

      autoscailing_group.properties.name = subject_config[:name]

      mock_call_api(
        subject,
        [
          {
            method: 'PATCH',
            path: "/cloudapi/autoscaling/groups/#{autoscailing_group.id}",
            operation: :'GroupsApi.autoscaling_groups_put',
            return_type: 'Group',
            body: { properties: expected_body },
            result: autoscailing_group,
          },
          {
            method: 'GET',
            path: "/cloudapi/autoscaling/groups/#{autoscailing_group.id}",
            operation: :'GroupsApi.autoscaling_groups_find_by_id',
            return_type: 'Group',
            result: autoscailing_group,
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