require 'spec_helper'
require 'ionoscloud_targetgroup_list'

Chef::Knife::IonoscloudTargetgroupList.load_deps

describe Chef::Knife::IonoscloudTargetgroupList do
  before :each do
    subject { Chef::Knife::IonoscloudTargetgroupList.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call DataCentersApi.datacenters_get' do
      target_groups = target_groups_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      target_group_list = [
        subject.ui.color('ID', :bold),
        subject.ui.color('Name', :bold),
        subject.ui.color('Algorithm', :bold),
        subject.ui.color('Protocol', :bold),
        subject.ui.color('Targets', :bold),
      ]

      target_groups.items.each do |target_group|
        target_group_list << target_group.id
        target_group_list << target_group.properties.name
        target_group_list << target_group.properties.algorithm
        target_group_list << target_group.properties.protocol
        target_group_list << target_group.properties.targets.nil? ? 0 : target_group.properties.targets.length
      end

      expect(subject.ui).to receive(:list).with(target_group_list, :uneven_columns_across, 5)

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: '/targetgroups',
            operation: :'TargetGroupsApi.targetgroups_get',
            return_type: 'TargetGroups',
            result: target_groups,
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
