require 'spec_helper'
require 'ionoscloud_dbaas_cluster_restore'

Chef::Knife::IonoscloudDbaasClusterRestore.load_deps

describe Chef::Knife::IonoscloudDbaasClusterRestore do
  before :each do
    subject { Chef::Knife::IonoscloudDbaasClusterRestore.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call RestoresApi.cluster_restore_post with the expected arguments and output based on what it receives' do
      cluster = cluster_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        cluster_id: cluster.id,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      mock_dbaas_call_api(
        subject,
        [
          {
            method: 'POST',
            path: "/clusters/#{subject_config[:cluster_id]}/restore",
            operation: :'RestoresApi.cluster_restore_post',
            result: nil,
            body: {},
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
