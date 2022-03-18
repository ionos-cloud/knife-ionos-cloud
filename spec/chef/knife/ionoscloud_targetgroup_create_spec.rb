require 'spec_helper'
require 'ionoscloud_targetgroup_create'

Chef::Knife::IonoscloudTargetgroupCreate.load_deps

describe Chef::Knife::IonoscloudTargetgroupCreate do
  before :each do
    subject { Chef::Knife::IonoscloudTargetgroupCreate.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call TargetGroupsApi.targetgroups_post_with_http_info with the expected arguments and output based on what it receives' do
      new_target = target_group_target_mock(
        ip: '127.9.9.9',
        port: 90,
        weight: 50,
        check: false,
        check_interval: 1234,
        maintenance: true,
      )
      target_group = target_group_mock(targets: [new_target])

      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        name: target_group.properties.name,
        algorithm: target_group.properties.algorithm,
        protocol: target_group.properties.protocol,
        check_timeout: target_group.properties.health_check.check_timeout,
        check_interval: target_group.properties.health_check.check_interval,
        retries: target_group.properties.health_check.retries,
        path: target_group.properties.http_health_check.path,
        method: target_group.properties.http_health_check.method,
        match_type: target_group.properties.http_health_check.match_type,
        response: target_group.properties.http_health_check.response,
        regex: target_group.properties.http_health_check.regex,
        negate: target_group.properties.http_health_check.negate,
        targets: [{
          'ip' => new_target.ip,
          'port' => new_target.port,
          'weight' => new_target.weight,
          'health_check_enabled' => new_target.health_check_enabled,
          'maintenance_enabled' => new_target.maintenance_enabled,
        }],
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

      expected_body = target_group.properties.to_hash

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'POST',
            path: '/targetgroups',
            operation: :'TargetGroupsApi.targetgroups_post',
            return_type: 'TargetGroup',
            body: { properties: expected_body },
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
