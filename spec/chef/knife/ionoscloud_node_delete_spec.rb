require 'spec_helper'
require 'ionoscloud_node_delete'

Chef::Knife::IonoscloudNodeDelete.load_deps

describe Chef::Knife::IonoscloudNodeDelete do
  before :each do
    subject { Chef::Knife::IonoscloudNodeDelete.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call KubernetesApi.k8s_nodepools_nodes_delete when the ID is valid' do
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

      expect(subject).to receive(:puts).with("ID: #{k8s_node.id}")
      expect(subject).to receive(:puts).with("Name: #{k8s_node.properties.name}")
      expect(subject).to receive(:puts).with("Public IP: #{k8s_node.properties.public_ip}")
      expect(subject).to receive(:puts).with("K8s Version: #{k8s_node.properties.k8s_version}")
      expect(subject).to receive(:puts).with("State: #{k8s_node.metadata.state}")
      expect(subject.ui).to receive(:warn).with("Deleted K8s Node #{k8s_node.id}.")

      expect(subject.api_client).not_to receive(:wait_for)
      expect(subject).not_to receive(:get_request_id)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/k8s/#{subject_config[:cluster_id]}/nodepools/#{subject_config[:nodepool_id]}/nodes/#{k8s_node.id}",
            operation: :'KubernetesApi.k8s_nodepools_nodes_find_by_id',
            return_type: 'KubernetesNode',
            result: k8s_node,
          },
          {
            method: 'DELETE',
            path: "/k8s/#{subject_config[:cluster_id]}/nodepools/#{subject_config[:nodepool_id]}/nodes/#{k8s_node.id}",
            operation: :'KubernetesApi.k8s_nodepools_nodes_delete',
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not call KubernetesApi.k8s_nodepools_nodes_delete when the ID is not valid' do
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
            method: 'GET',
            path: "/k8s/#{subject_config[:cluster_id]}/nodepools/#{subject_config[:nodepool_id]}/nodes/#{k8s_node_id}",
            operation: :'KubernetesApi.k8s_nodepools_nodes_find_by_id',
            return_type: 'KubernetesNode',
            exception: Ionoscloud::ApiError.new(code: 404),
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not make any call if any required option is missing' do
      check_required_options(subject)
    end
  end
end
