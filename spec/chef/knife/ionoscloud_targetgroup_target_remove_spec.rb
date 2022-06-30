require 'spec_helper'
require 'ionoscloud_targetgroup_target_remove'

Chef::Knife::IonoscloudTargetgroupTargetRemove.load_deps

describe Chef::Knife::IonoscloudTargetgroupTargetRemove do
  before :each do
    subject { Chef::Knife::IonoscloudTargetgroupTargetRemove.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should not call TargetGroupsApi.targetgroups_patch when the specified target does not exist in the Target Group' do
      target_group = target_group_mock
      target = target_group_target_mock(ip: '127.0.0.2', port: 22)

      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        target_group_id: target_group.id,
        ip: target.ip,
        port: target.port,
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      health_check, http_health_check, targets = subject.get_target_group_extended_properties(target_group)

      expect(subject).to receive(:puts).with("ID: #{target_group.id}")
      expect(subject).to receive(:puts).with("Name: #{target_group.properties.name}")
      expect(subject).to receive(:puts).with("Algorithm: #{target_group.properties.algorithm}")
      expect(subject).to receive(:puts).with("Protocol: #{target_group.properties.protocol}")
      expect(subject).to receive(:puts).with("Health Check: #{health_check}")
      expect(subject).to receive(:puts).with("HTTP Health Check: #{http_health_check}")
      expect(subject).to receive(:puts).with("Targets: #{targets}")

      expect(subject.ui).to receive(:warn).with("Specified target does not exist (#{subject_config[:ip]}:#{subject_config[:port]}).")

      expect(subject).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/targetgroups/#{target_group.id}",
            operation: :'TargetGroupsApi.targetgroups_find_by_target_group_id',
            return_type: 'TargetGroup',
            result: target_group,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should call TargetGroupsApi.targetgroups_patch and remove the target when it exists' do
      target_group = target_group_mock
      target = target_group_target_mock

      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        target_group_id: target_group.id,
        ip: target.ip,
        port: target.port,
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      health_check, http_health_check, _ = subject.get_target_group_extended_properties(target_group)

      expect(subject).to receive(:puts).with("ID: #{target_group.id}")
      expect(subject).to receive(:puts).with("Name: #{target_group.properties.name}")
      expect(subject).to receive(:puts).with("Algorithm: #{target_group.properties.algorithm}")
      expect(subject).to receive(:puts).with("Protocol: #{target_group.properties.protocol}")
      expect(subject).to receive(:puts).with("Health Check: #{health_check}")
      expect(subject).to receive(:puts).with("HTTP Health Check: #{http_health_check}")
      expect(subject).to receive(:puts).with("Targets: #{[]}")

      expected_properties = target_group.properties.to_hash
      expected_properties[:targets] = []

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/targetgroups/#{target_group.id}",
            operation: :'TargetGroupsApi.targetgroups_find_by_target_group_id',
            return_type: 'TargetGroup',
            result: target_group,
          },
          {
            method: 'PATCH',
            path: "/targetgroups/#{target_group.id}",
            operation: :'TargetGroupsApi.targetgroups_patch',
            body: expected_properties,
            return_type: 'TargetGroup',
            result: target_group,
          },
          {
            method: 'GET',
            path: "/targetgroups/#{target_group.id}",
            operation: :'TargetGroupsApi.targetgroups_find_by_target_group_id',
            return_type: 'TargetGroup',
            result: target_group,
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
