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

      maintenance_window = "#{cluster.properties.maintenance_window.day_of_the_week}, #{cluster.properties.maintenance_window.time}"
      s3_buckets = (cluster.properties.s3_buckets.nil? ? [] : cluster.properties.s3_buckets.map { |el| el.name })

      expect(subject).to receive(:puts).with("ID: #{cluster.id}")
      expect(subject).to receive(:puts).with("Name: #{cluster.properties.name}")
      expect(subject).to receive(:puts).with("k8s Version: #{cluster.properties.k8s_version}")
      expect(subject).to receive(:puts).with("Maintenance Window: #{maintenance_window}")
      expect(subject).to receive(:puts).with("State: #{cluster.metadata.state}")
      expect(subject).to receive(:puts).with("Api Subnet Allow List: #{cluster.properties.api_subnet_allow_list}")
      expect(subject).to receive(:puts).with("S3 Buckets: #{s3_buckets}")
      expect(subject).to receive(:puts).with("Available Upgrade Versions: #{cluster.properties.available_upgrade_versions}")
      expect(subject).to receive(:puts).with("Viable NodePool Versions: #{cluster.properties.viable_node_pool_versions}")

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
      required_options = subject.instance_variable_get(:@required_options)

      if required_options.length > 0
        arrays_without_one_element(required_options).each do |test_case|
          subject.config[:ionoscloud_token] = 'token'
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
end
