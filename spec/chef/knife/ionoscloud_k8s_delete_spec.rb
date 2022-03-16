require 'spec_helper'
require 'ionoscloud_k8s_delete'

Chef::Knife::IonoscloudK8sDelete.load_deps

describe Chef::Knife::IonoscloudK8sDelete do
  before :each do
    subject { Chef::Knife::IonoscloudK8sDelete.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call KubernetesApi.k8s_delete when the ID is valid' do
      cluster = k8s_cluster_mock({ entities: Ionoscloud::KubernetesClusterEntities.new(
        nodepools: k8s_nodepools_mock({ items: [] }),
      ) })
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [cluster.id]

      maintenance_window = "#{cluster.properties.maintenance_window.day_of_the_week}, #{cluster.properties.maintenance_window.time}"
      s3_buckets = (cluster.properties.s3_buckets.nil? ? [] : cluster.properties.s3_buckets.map { |el| el.name })

      expect(subject).to receive(:puts).with("ID: #{cluster.id}")
      expect(subject).to receive(:puts).with("Name: #{cluster.properties.name}")
      expect(subject).to receive(:puts).with("Public: #{cluster.properties.public}")
      expect(subject).to receive(:puts).with("k8s Version: #{cluster.properties.k8s_version}")
      expect(subject).to receive(:puts).with("Maintenance Window: #{maintenance_window}")
      expect(subject).to receive(:puts).with("State: #{cluster.metadata.state}")
      expect(subject).to receive(:puts).with("Api Subnet Allow List: #{cluster.properties.api_subnet_allow_list}")
      expect(subject).to receive(:puts).with("S3 Buckets: #{s3_buckets}")
      expect(subject).to receive(:puts).with("Available Upgrade Versions: #{cluster.properties.available_upgrade_versions}")
      expect(subject).to receive(:puts).with("Viable NodePool Versions: #{cluster.properties.viable_node_pool_versions}")
      expect(subject.ui).to receive(:warn).with("Deleted K8s Cluster #{cluster.id}. Request ID: ")

      expect(subject).not_to receive(:wait_for)
      expect(subject).to receive(:get_request_id).once
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
          {
            method: 'DELETE',
            path: "/k8s/#{cluster.id}",
            operation: :'KubernetesApi.k8s_delete',
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not call KubernetesApi.k8s_delete when the ID is not valid' do
      k8s_cluster_id = 'invalid_id'
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [k8s_cluster_id]

      expect(subject.ui).to receive(:error).with("K8s Cluster ID #{k8s_cluster_id} not found. Skipping.")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/k8s/#{k8s_cluster_id}",
            operation: :'KubernetesApi.k8s_find_by_cluster_id',
            return_type: 'KubernetesCluster',
            exception: Ionoscloud::ApiError.new(code: 404),
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not call KubernetesApi.k8s_delete when the cluster is not one of ["ACTIVE", "TERMINATED"]' do
      k8s_cluster = k8s_cluster_mock(
        {
          state: 'DEPLOYING',
          entities: Ionoscloud::KubernetesClusterEntities.new(
            nodepools: k8s_nodepools_mock({ items: [] }),
          ),
        },
      )
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [k8s_cluster.id]

      expect(subject.ui).to receive(:error).with(
        "K8s Cluster #{k8s_cluster.id} state must be one of ['ACTIVE', 'TERMINATED'], "\
        "actual state is '#{k8s_cluster.metadata.state}'. Skipping.",
      )

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/k8s/#{k8s_cluster.id}",
            operation: :'KubernetesApi.k8s_find_by_cluster_id',
            return_type: 'KubernetesCluster',
            result: k8s_cluster,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not call KubernetesApi.k8s_delete when the cluster has existing Nodepools' do
      k8s_cluster = k8s_cluster_mock()
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [k8s_cluster.id]

      expect(subject.ui).to receive(:error).with("K8s Cluster ID #{k8s_cluster.id} has existing Nodepools. Skipping.")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/k8s/#{k8s_cluster.id}",
            operation: :'KubernetesApi.k8s_find_by_cluster_id',
            return_type: 'KubernetesCluster',
            result: k8s_cluster,
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
