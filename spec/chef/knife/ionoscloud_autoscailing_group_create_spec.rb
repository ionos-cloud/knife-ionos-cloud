require 'spec_helper'
require 'ionoscloud_autoscailing_group_create'

Chef::Knife::IonoscloudAutoscailingGroupCreate.load_deps

describe Chef::Knife::IonoscloudAutoscailingGroupCreate do
  before :each do
    subject { Chef::Knife::IonoscloudAutoscailingGroupCreate.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call GroupsApi.autoscaling_groups_post with the expected arguments and output based on what it receives' do
      autoscailing_group = vm_autoscailing_group_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        group_id: 'group_id',
        # todo vezi daca trebuie sa pui si type
        max_replica_count: autoscailing_group.properties.max_replica_count,
        min_replica_count: autoscailing_group.properties.min_replica_count,
        target_replica_count: autoscailing_group.properties.target_replica_count,
        name: autoscailing_group.properties.name,
        policy: autoscailing_group.properties.policy, # todo vezi daca e ok sunt json date din fisier
        replica_configuration: autoscailing_group.properties.replica_configuration, # todo vezi daca e ok
        resource_id: autoscailing_group.properties.datacenter.id,
        resource_type: autoscailing_group.properties.datacenter.type,
        location: autoscailing_group.properties.location,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{autoscailing_group.id}")
      expect(subject).to receive(:puts).with("TYPE: #{autoscailing_group.type}")
      expect(subject).to receive(:puts).with("MAX REPLICA COUNT: #{autoscailing_group.properties.max_replica_count}")
      expect(subject).to receive(:puts).with("MIN REPLICA COUNT: #{autoscailing_group.properties.min_replica_count}")
      expect(subject).to receive(:puts).with("TARGET REPLICA COUNT: #{autoscailing_group.properties.target_replica_count}")
      expect(subject).to receive(:puts).with("NAME: #{autoscailing_group.properties.name}")
      expect(subject).to receive(:puts).with("POLICY: #{autoscailing_group.properties.policy}")
      expect(subject).to receive(:puts).with("REPLICA CONFIGURATION: #{autoscailing_group.properties.replica_configuration}")
      expect(subject).to receive(:puts).with("DATACENTER: #{autoscailing_group.properties.datacenter}")
      expect(subject).to receive(:puts).with("LOCATION: #{autoscailing_group.properties.location}")

      expected_body = autoscailing_group.properties.to_hash
      expected_body[:credentials] = { username: subject_config[:username], password: subject_config[:password] }
      # expected_body[:fromBackup] = {}

      mock_dbaas_call_api(
        subject,
        [
          {
            method: 'POST',
            path: '/autoscaling/groups',
            operation: :'GroupsApi.autoscaling_groups_post',
            return_type: 'GroupPostResponse',
            body: { properties: expected_body },
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
        expect(subject.api_client_dbaas).not_to receive(:call_api)

        expect { subject.run }.to raise_error(SystemExit) do |error|
          expect(error.status).to eq(1)
        end

        required_options.each { |value| subject.config[value] = nil }
      end
    end
  end
end