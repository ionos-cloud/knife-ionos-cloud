require 'spec_helper'
require 'ionoscloud_nodepool_get'

Chef::Knife::IonoscloudNodepoolGet.load_deps

describe Chef::Knife::IonoscloudNodepoolGet do
  before :each do
    subject { Chef::Knife::IonoscloudNodepoolGet.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call KubernetesApi.k8s_nodepools_nodes_find_by_id' do
      nodepool = k8s_nodepool_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        cluster_id: 'cluster_id',
        nodepool_id: nodepool.id,
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      check_k8s_nodepool_print(subject, nodepool)

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/k8s/#{subject_config[:cluster_id]}/nodepools/#{subject_config[:nodepool_id]}",
            operation: :'KubernetesApi.k8s_nodepools_find_by_id',
            return_type: 'KubernetesNodePool',
            result: nodepool,
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
