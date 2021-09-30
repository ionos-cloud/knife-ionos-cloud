require 'spec_helper'
require 'ionoscloud_k8s_create'

Chef::Knife::IonoscloudK8sCreate.load_deps

describe Chef::Knife::IonoscloudK8sCreate do
  before :each do
    subject { Chef::Knife::IonoscloudK8sCreate.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call KubernetesApi.k8s_post with the expected arguments and output based on what it receives' do
      cluster = k8s_cluster_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        name: cluster.properties.name,
        version: cluster.properties.k8s_version,
        maintenance_day: cluster.properties.maintenance_window.day_of_the_week,
        maintenance_time: cluster.properties.maintenance_window.time,
        s3_buckets: cluster.properties.s3_buckets.map { |el| el.name }.join(','),
        api_subnet_allow_list: cluster.properties.api_subnet_allow_list.join(','),
      }

      subject_config.each { |key, value| subject.config[key] = value }

      check_k8s_cluster_print(subject, cluster)

      expected_body = cluster.properties.to_hash
      expected_body.delete(:viableNodePoolVersions)
      expected_body.delete(:availableUpgradeVersions)

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'POST',
            path: '/k8s',
            operation: :'KubernetesApi.k8s_post',
            return_type: 'KubernetesCluster',
            body: { properties: expected_body },
            result: cluster,
          },
          {
            method: 'GET',
            path: "/k8s/#{cluster.id}",
            operation: :'KubernetesApi.k8s_find_by_cluster_id',
            return_type: 'KubernetesCluster',
            result: cluster,
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
