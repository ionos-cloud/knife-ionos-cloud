require 'spec_helper'
require 'ionoscloud_node_list'

Chef::Knife::IonoscloudNodeList.load_deps

describe Chef::Knife::IonoscloudNodeList do
  before :each do
    subject { Chef::Knife::IonoscloudNodeList.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call KubernetesApi.k8s_nodepools_nodes_get' do
      k8s_nodes = k8s_nodes_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        cluster_id: 'cluster_id',
        nodepool_id: 'nodepool_id',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      node_list = [
        subject.ui.color('ID', :bold),
        subject.ui.color('Name', :bold),
        subject.ui.color('Public IP', :bold),
        subject.ui.color('Private IP', :bold),
        subject.ui.color('K8s Version', :bold),
        subject.ui.color('State', :bold),
        k8s_nodes.items.first.id,
        k8s_nodes.items.first.properties.name,
        k8s_nodes.items.first.properties.public_ip,
        k8s_nodes.items.first.properties.private_ip,
        k8s_nodes.items.first.properties.k8s_version,
        k8s_nodes.items.first.metadata.state,
      ]

      expect(subject.ui).to receive(:list).with(node_list, :uneven_columns_across, 6)

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/k8s/#{subject_config[:cluster_id]}/nodepools/#{subject_config[:nodepool_id]}/nodes",
            operation: :'KubernetesApi.k8s_nodepools_nodes_get',
            return_type: 'KubernetesNodes',
            result: k8s_nodes,
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
