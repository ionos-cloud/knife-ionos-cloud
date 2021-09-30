require 'spec_helper'
require 'ionoscloud_nodepool_delete'

Chef::Knife::IonoscloudNodepoolDelete.load_deps

describe Chef::Knife::IonoscloudNodepoolDelete do
  before :each do
    subject { Chef::Knife::IonoscloudNodepoolDelete.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call KubernetesApi.k8s_nodepools_delete when the ID is valid' do
      nodepool = k8s_nodepool_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        cluster_id: 'cluster_id',
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [nodepool.id]

      check_k8s_nodepool_print(subject, nodepool)
      expect(subject.ui).to receive(:warn).with("Deleted K8s Nodepool #{nodepool.id}.")

      expect(subject.api_client).not_to receive(:wait_for)
      expect(subject).not_to receive(:get_request_id)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/k8s/#{subject_config[:cluster_id]}/nodepools/#{nodepool.id}",
            operation: :'KubernetesApi.k8s_nodepools_find_by_id',
            return_type: 'KubernetesNodePool',
            result: nodepool,
          },
          {
            method: 'DELETE',
            path: "/k8s/#{subject_config[:cluster_id]}/nodepools/#{nodepool.id}",
            operation: :'KubernetesApi.k8s_nodepools_delete',
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not call KubernetesApi.k8s_nodepools_delete when the ID is not valid' do
      k8s_nodepool_id = 'invalid_id'
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        cluster_id: 'cluster_id',
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [k8s_nodepool_id]

      expect(subject.ui).to receive(:error).with("K8s Nodepool ID #{k8s_nodepool_id} not found. Skipping.")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/k8s/#{subject_config[:cluster_id]}/nodepools/#{k8s_nodepool_id}",
            operation: :'KubernetesApi.k8s_nodepools_find_by_id',
            return_type: 'KubernetesNodePool',
            exception: Ionoscloud::ApiError.new(code: 404),
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
