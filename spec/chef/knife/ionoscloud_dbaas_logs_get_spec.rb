require 'spec_helper'
require 'ionoscloud_dbaas_logs_get'

Chef::Knife::IonoscloudDbaasLogsGet.load_deps

describe Chef::Knife::IonoscloudDbaasLogsGet do
  before :each do
    subject { Chef::Knife::IonoscloudDbaasLogsGet.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call LogsApi.cluster_logs_get' do
      cluster_logs = cluster_logs_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        cluster_id: 'cluster_id',
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      cluster_logs.instances.each do
        |instance|
        expect(subject).to receive(:puts).with("Instance Name: #{instance.name}")
        expect(subject).to receive(:puts).with(instance.messages.map { |message| message.message })
      end

      mock_dbaas_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/clusters/#{subject_config[:cluster_id]}/logs",
            operation: :'LogsApi.cluster_logs_get',
            return_type: 'ClusterLogs',
            result: cluster_logs,
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