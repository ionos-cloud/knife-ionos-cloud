require 'spec_helper'
require 'ionoscloud_nodepool_list'

Chef::Knife::IonoscloudNodepoolList.load_deps

describe Chef::Knife::IonoscloudNodepoolList do
  before :each do
    subject { Chef::Knife::IonoscloudNodepoolList.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call KubernetesApi.k8s_nodepools_get' do
      k8s_nodepools = k8s_nodepools_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        cluster_id: 'cluster_id',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      nodepool_list = [
        subject.ui.color('ID', :bold),
        subject.ui.color('Name', :bold),
        subject.ui.color('K8s Version', :bold),
        subject.ui.color('Datacenter ID', :bold),
        subject.ui.color('Node Count', :bold),
        subject.ui.color('Lan Count', :bold),
        subject.ui.color('State', :bold),
        k8s_nodepools.items.first.id,
        k8s_nodepools.items.first.properties.name,
        k8s_nodepools.items.first.properties.k8s_version,
        k8s_nodepools.items.first.properties.datacenter_id,
        k8s_nodepools.items.first.properties.node_count.to_s,
        k8s_nodepools.items.first.properties.lans.length,
        k8s_nodepools.items.first.metadata.state,
      ]

      expect(subject.ui).to receive(:list).with(nodepool_list, :uneven_columns_across, 7)

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/k8s/#{subject_config[:cluster_id]}/nodepools",
            operation: :'KubernetesApi.k8s_nodepools_get',
            return_type: 'KubernetesNodePools',
            result: k8s_nodepools,
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
