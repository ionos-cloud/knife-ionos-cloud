require 'spec_helper'
require 'ionoscloud_k8s_list'

Chef::Knife::IonoscloudK8sList.load_deps

describe Chef::Knife::IonoscloudK8sList do
  before :each do
    subject { Chef::Knife::IonoscloudK8sList.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call KubernetesApi.k8s_get' do
      k8s_clusters = k8s_clusters_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      cluster_list = [
        subject.ui.color('ID', :bold),
        subject.ui.color('Name', :bold),
        subject.ui.color('Version', :bold),
        subject.ui.color('Maintenance Window', :bold),
        subject.ui.color('State', :bold),
        k8s_clusters.items.first.id,
        k8s_clusters.items.first.properties.name,
        k8s_clusters.items.first.properties.k8s_version,
        "#{k8s_clusters.items.first.properties.maintenance_window.day_of_the_week}, #{k8s_clusters.items.first.properties.maintenance_window.time}",
        k8s_clusters.items.first.metadata.state,
      ]

      expect(subject.ui).to receive(:list).with(cluster_list, :uneven_columns_across, 5)

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: '/k8s',
            operation: :'KubernetesApi.k8s_get',
            return_type: 'KubernetesClusters',
            result: k8s_clusters,
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
