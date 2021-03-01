require 'spec_helper'
require 'ionoscloud_node_replace'

Chef::Knife::IonoscloudNodeReplace.load_deps

describe Chef::Knife::IonoscloudNodeReplace do
  before :each do
    subject { Chef::Knife::IonoscloudNodeReplace.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call KubernetesApi.k8s_nodepools_nodes_replace_post and succeed when the ID is valid' do
      k8s_node = k8s_node_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        cluster_id: 'cluster_id',
        nodepool_id: 'nodepool_id',
        yes: true,
      }
 
      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [k8s_node.id]

      expect(subject.ui).to receive(:warn).with("Recreated K8s Node #{k8s_node.id}.")

      expect(subject.api_client).not_to receive(:wait_for)
      expect(subject).not_to receive(:get_request_id)
      mock_call_api(
        subject,
        [
          {
            method: 'POST',
            path: "/k8s/#{subject_config[:cluster_id]}/nodepools/#{subject_config[:nodepool_id]}/nodes/#{k8s_node.id}/replace",
            operation: :'KubernetesApi.k8s_nodepools_nodes_replace_post',
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not call KubernetesApi.k8s_nodepools_nodes_replace_post and not succeed when the ID is not valid' do
      k8s_node_id = 'invalid_id'
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        cluster_id: 'cluster_id',
        nodepool_id: 'nodepool_id',
      }
 
      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [k8s_node_id]

      expect(subject.ui).to receive(:error).with("K8s Node ID #{k8s_node_id} not found. Skipping.")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'POST',
            path: "/k8s/#{subject_config[:cluster_id]}/nodepools/#{subject_config[:nodepool_id]}/nodes/#{k8s_node_id}/replace",
            operation: :'KubernetesApi.k8s_nodepools_nodes_replace_post',
            exception: Ionoscloud::ApiError.new(:code => 404),
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
