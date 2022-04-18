require 'spec_helper'
require 'ionoscloud_kubeconfig_get'

Chef::Knife::IonoscloudKubeconfigGet.load_deps

describe Chef::Knife::IonoscloudKubeconfigGet do
  subject { Chef::Knife::IonoscloudKubeconfigGet.new }

  describe '#run' do
    it 'should call KubernetesApi.k8s_kubeconfig_get and output the received url when the cluster ID is valid' do
      kubeconfig = kubeconfig_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        cluster_id: 'cluster_id',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with(kubeconfig)

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/k8s/#{subject_config[:cluster_id]}/kubeconfig",
            operation: :'KubernetesApi.k8s_kubeconfig_get',
            return_type: 'String',
            result: kubeconfig,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should output an error is the cluster is not found' do
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        cluster_id: 'invalid_id',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      allow(subject).to receive(:puts)
      allow(subject).to receive(:print)

      expect(subject.ui).to receive(:error).with("K8s Cluster ID #{subject_config[:cluster_id]} not found.")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/k8s/#{subject_config[:cluster_id]}/kubeconfig",
            operation: :'KubernetesApi.k8s_kubeconfig_get',
            return_type: 'String',
            exception: Ionoscloud::ApiError.new(code: 404),
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not make any call if any required option is missing' do
      required_options = subject.instance_variable_get(:@required_options)
      allow(subject).to receive(:puts)
      allow(subject).to receive(:print)

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
