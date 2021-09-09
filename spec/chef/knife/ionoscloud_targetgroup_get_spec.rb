require 'spec_helper'
require 'ionoscloud_targetgroup_get'

Chef::Knife::IonoscloudTargetgroupGet.load_deps

describe Chef::Knife::IonoscloudTargetgroupGet do
  before :each do
    subject { Chef::Knife::IonoscloudTargetgroupGet.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call TargetGroupsApi.targetgroups_find_by_target_group_id' do
      target_group = target_group_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        target_group_id: target_group.id,
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

      mock_call_api(
        subject,
        [
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
