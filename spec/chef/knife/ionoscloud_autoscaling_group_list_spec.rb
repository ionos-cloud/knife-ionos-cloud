require 'spec_helper'
require 'ionoscloud_autoscaling_group_list'

Chef::Knife::IonoscloudVmAutoscalingGroupList.load_deps

describe Chef::Knife::IonoscloudVmAutoscalingGroupList do
  before :each do
    subject { Chef::Knife::IonoscloudVmAutoscalingGroupList.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call GroupsApi.clusters_get' do
      autoscaling_groups = vm_autoscaling_groups_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      autoscaling_group_list = [
        subject.ui.color('ID', :bold),
        subject.ui.color('Type', :bold),
        subject.ui.color('Max Replica Count', :bold),
        subject.ui.color('Min Replica Count', :bold),
        subject.ui.color('Target Replica Count', :bold),
        subject.ui.color('Name', :bold),
        subject.ui.color('Policy', :bold),
        subject.ui.color('Replica Configuration', :bold),
        subject.ui.color('Datacenter', :bold),
        subject.ui.color('Location', :bold),
      ]

      autoscaling_groups.items.each do |autoscaling_group|
        autoscaling_group_list << autoscaling_group.id
        autoscaling_group_list << autoscaling_group.type
        autoscaling_group_list << autoscaling_group.properties.max_replica_count
        autoscaling_group_list << autoscaling_group.properties.min_replica_count
        autoscaling_group_list << autoscaling_group.properties.target_replica_count
        autoscaling_group_list << autoscaling_group.properties.name
        autoscaling_group_list << autoscaling_group.properties.policy
        autoscaling_group_list << autoscaling_group.properties.replica_configuration
        autoscaling_group_list << autoscaling_group.properties.datacenter
        autoscaling_group_list << autoscaling_group.properties.location 
      end

      expect(subject.ui).to receive(:list).with(autoscaling_group_list, :uneven_columns_across, 10)

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: '/cloudapi/autoscaling/groups',
            operation: :'GroupsApi.autoscaling_groups_get',
            return_type: 'GroupCollection',
            result: autoscaling_groups,
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