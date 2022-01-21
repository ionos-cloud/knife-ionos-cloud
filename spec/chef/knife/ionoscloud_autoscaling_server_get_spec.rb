require 'spec_helper'
require 'ionoscloud_autoscaling_server_get'

Chef::Knife::IonoscloudAutoscalingGrouServerpGet.load_deps

describe Chef::Knife::IonoscloudAutoscalingGrouServerpGet do
  before :each do
    subject { Chef::Knife::IonoscloudAutoscalingGrouServerpGet.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call AutoscailingApi.autoscaling_groups_servers_find_by_id' do
      group_server = vm_autoscailing_group_server_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        group_id: 'group_id',
        server_id: group_server.id,
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{group_server.id}")
      expect(subject).to receive(:puts).with("DATACENTER SERVER: #{group_server.properties.datacenter_server}")
      expect(subject).to receive(:puts).with("NAME: #{group_server.properties.name}")
      

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/cloudapi/autoscaling/groups/#{subject_config[:group_id]}/servers//#{subject_config[:server_id]}",
            operation: :'GroupsApi.autoscaling_groups_servers_find_by_id',
            return_type: 'Group',
            result: group_server,
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