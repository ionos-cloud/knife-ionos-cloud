require 'spec_helper'
require 'ionoscloud_nodepool_create'

Chef::Knife::IonoscloudNodepoolCreate.load_deps

describe Chef::Knife::IonoscloudNodepoolCreate do
  before :each do
    subject { Chef::Knife::IonoscloudNodepoolCreate.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call KubernetesApi.k8s_nodepools_post with the expected arguments and output based on what it receives' do
      nodepool = k8s_nodepool_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        cluster_id: 'cluster_id',
        datacenter_id: nodepool.properties.datacenter_id,
        name: nodepool.properties.name,
        k8s_version: nodepool.properties.k8s_version,
        maintenance_day: nodepool.properties.maintenance_window.day_of_the_week,
        maintenance_time: nodepool.properties.maintenance_window.time,
        node_count: nodepool.properties.node_count,
        cpu_family: nodepool.properties.cpu_family,
        cores: nodepool.properties.cores_count,
        ram: nodepool.properties.ram_size,
        availability_zone: nodepool.properties.availability_zone,
        storage_type: nodepool.properties.storage_type,
        storage_size: nodepool.properties.storage_size,
        min_node_count: nodepool.properties.auto_scaling.min_node_count,
        max_node_count: nodepool.properties.auto_scaling.max_node_count,
        lans: nodepool.properties.lans.map { |lan| lan.id }.join(','),
        public_ips: nodepool.properties.public_ips.join(','),
      }

      subject_config.each { |key, value| subject.config[key] = value }

      check_k8s_nodepool_print(subject, nodepool)

      expected_body = nodepool.properties.to_hash
      expected_body[:lans].map! { |lan| lan.delete(:properties); lan[:id] = Integer(lan[:id]); lan }
      expected_body.delete(:availableUpgradeVersions)
      expected_body.delete(:labels)
      expected_body.delete(:annotations)

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'POST',
            path: "/k8s/#{subject_config[:cluster_id]}/nodepools",
            operation: :'KubernetesApi.k8s_nodepools_post',
            return_type: 'KubernetesNodePool',
            body: { properties: expected_body },
            result: nodepool,
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
