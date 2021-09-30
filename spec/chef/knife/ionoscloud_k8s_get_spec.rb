require 'spec_helper'
require 'ionoscloud_k8s_get'

Chef::Knife::IonoscloudK8sGet.load_deps

describe Chef::Knife::IonoscloudK8sGet do
  before :each do
    subject { Chef::Knife::IonoscloudK8sGet.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call KubernetesApi.k8s_find_by_cluster_id' do
      cluster = k8s_cluster_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        cluster_id: cluster.id,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      check_k8s_cluster_print(subject, cluster)

      mock_call_api(
        subject,
        [
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
