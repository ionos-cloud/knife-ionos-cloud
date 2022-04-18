require 'spec_helper'
require 'ionoscloud_autoscaling_server_list'

Chef::Knife::IonoscloudVmAutoscalingGroupServerList.load_deps

describe Chef::Knife::IonoscloudVmAutoscalingGroupServerList do
  before :each do
    subject { Chef::Knife::IonoscloudVmAutoscalingGroupServerList.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call GroupsApi.autoscaling_groups_servers_get' do
      servers_group = vm_autoscaling_servers_group
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        group_id: 'group_id'
      }

      subject_config.each { |key, value| subject.config[key] = value }

      servers_list = [
        subject.ui.color('ID', :bold),
        subject.ui.color('TYPE', :bold),
      ]

      servers_group.items.each do |server|
        servers_list << server.id
        servers_list << server.type
      end

      expect(subject.ui).to receive(:list).with(servers_list, :uneven_columns_across, 2)

      mock_vm_autoscaling_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/cloudapi/autoscaling/groups/#{subject_config[:group_id]}/servers",
            operation: :'GroupsApi.autoscaling_groups_servers_get',
            return_type: 'ServerCollection',
            result: servers_group,
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