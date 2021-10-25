require 'spec_helper'
require 'ionoscloud_targetgroup_update'

Chef::Knife::IonoscloudTargetgroupUpdate.load_deps

describe Chef::Knife::IonoscloudTargetgroupUpdate do
  before :each do
    subject { Chef::Knife::IonoscloudTargetgroupUpdate.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call TargetGroupsApi.targetgroups_patch' do
      new_target = target_group_target_mock(
        ip: '127.9.9.9',
        port: 90,
        weight: 50,
        check: false,
        check_interval: 1234,
        maintenance: true,
      )
      target_group = target_group_mock

      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        target_group_id: 'target_group_id',
        name: target_group.properties.name + '_edited',
        algorithm: 'RANDOM',
        check_timeout: target_group.properties.health_check.check_timeout + 100,
        connect_timeout: target_group.properties.health_check.connect_timeout + 100,
        target_timeout: target_group.properties.health_check.target_timeout + 100,
        retries: target_group.properties.health_check.retries + 10,
        path: target_group.properties.http_health_check.path + '_edited',
        method: 'POST',
        response: target_group.properties.http_health_check.response + ' edited',
        regex: !target_group.properties.http_health_check.regex,
        negate: !target_group.properties.http_health_check.negate,
        targets: [{
          'ip' => new_target.ip,
          'port' => new_target.port,
          'weight' => new_target.weight,
          'health_check' => {
            'check' => new_target.health_check.check,
            'check_interval' => new_target.health_check.check_interval,
            'maintenance' => new_target.health_check.maintenance,
          },
        }],
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }


      target_group.properties.name = subject_config[:name]
      target_group.properties.algorithm = subject_config[:algorithm]
      target_group.properties.health_check.check_timeout = subject_config[:check_timeout]
      target_group.properties.health_check.connect_timeout = subject_config[:connect_timeout]
      target_group.properties.health_check.target_timeout = subject_config[:target_timeout]
      target_group.properties.health_check.retries = subject_config[:retries]
      target_group.properties.health_check.check_timeout = subject_config[:check_timeout]
      target_group.properties.http_health_check.method = subject_config[:method]
      target_group.properties.http_health_check.path = subject_config[:path]
      target_group.properties.http_health_check.response = subject_config[:response]
      target_group.properties.http_health_check.regex = subject_config[:regex]
      target_group.properties.http_health_check.negate = subject_config[:negate]

      target_group.properties.targets = [new_target]

      health_check, http_health_check, targets = subject.get_target_group_extended_properties(target_group)

      expect(subject).to receive(:puts).with("ID: #{target_group.id}")
      expect(subject).to receive(:puts).with("Name: #{target_group.properties.name}")
      expect(subject).to receive(:puts).with("Algorithm: #{target_group.properties.algorithm}")
      expect(subject).to receive(:puts).with("Protocol: #{target_group.properties.protocol}")
      expect(subject).to receive(:puts).with("Health Check: #{health_check}")
      expect(subject).to receive(:puts).with("HTTP Health Check: #{http_health_check}")
      expect(subject).to receive(:puts).with("Targets: #{targets}")

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'PATCH',
            path: "/targetgroups/#{subject_config[:target_group_id]}",
            operation: :'TargetGroupsApi.targetgroups_patch',
            return_type: 'TargetGroup',
            body: {
              name: subject_config[:name],
              algorithm: subject_config[:algorithm],
              healthCheck: {
                checkTimeout: subject_config[:check_timeout],
                connectTimeout: subject_config[:connect_timeout],
                targetTimeout: subject_config[:target_timeout],
                retries: subject_config[:retries],
              },
              httpHealthCheck: {
                method: subject_config[:method],
                path: subject_config[:path],
                response: subject_config[:response],
                regex: subject_config[:regex],
                negate: subject_config[:negate],
              },
              targets: [{
                ip: new_target.ip,
                port: new_target.port,
                weight: new_target.weight,
                healthCheck: {
                  check: new_target.health_check.check,
                  checkInterval: new_target.health_check.check_interval,
                  maintenance: new_target.health_check.maintenance,
                },
              }],
            },
            result: target_group,
          },
          {
            method: 'GET',
            path: "/targetgroups/#{subject_config[:target_group_id]}",
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
