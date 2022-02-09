require 'spec_helper'
require 'ionoscloud_k8s_update'

Chef::Knife::IonoscloudK8sUpdate.load_deps

describe Chef::Knife::IonoscloudK8sUpdate do
  before :each do
    subject { Chef::Knife::IonoscloudK8sUpdate.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call NicApi.datacenters_servers_nics_clusterrules_patch' do
      cluster = k8s_cluster_mock

      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        cluster_id: cluster.id,
        name: cluster.properties.name + '_edited',
        version: '19.9.9',
        maintenance_day: 'Monday',
        maintenance_time: '13:03:19Z',
        api_subnet_allow_list: (cluster.properties.api_subnet_allow_list + ['127.0.0.3']).join(','),
        s3_buckets: (cluster.properties.s3_buckets.map { |el| el.name } + ['new_bucket']).join(','),
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      maintenance_window = "#{subject_config[:maintenance_day]}, #{subject_config[:maintenance_time]}"
      s3_buckets = (cluster.properties.s3_buckets.map { |el| el.name } + ['new_bucket'])

      expect(subject).to receive(:puts).with("ID: #{cluster.id}")
      expect(subject).to receive(:puts).with("Name: #{subject_config[:name]}")
      expect(subject).to receive(:puts).with("k8s Version: #{subject_config[:version]}")
      expect(subject).to receive(:puts).with("Maintenance Window: #{maintenance_window}")
      expect(subject).to receive(:puts).with("State: #{cluster.metadata.state}")
      expect(subject).to receive(:puts).with("Api Subnet Allow List: #{cluster.properties.api_subnet_allow_list + ['127.0.0.3']}")
      expect(subject).to receive(:puts).with("S3 Buckets: #{s3_buckets}")
      expect(subject).to receive(:puts).with("Available Upgrade Versions: #{cluster.properties.available_upgrade_versions}")
      expect(subject).to receive(:puts).with("Viable NodePool Versions: #{cluster.properties.viable_node_pool_versions}")

      cluster.properties.name = subject_config[:name]
      cluster.properties.k8s_version = subject_config[:version]
      cluster.properties.maintenance_window.day_of_the_week = subject_config[:maintenance_day]
      cluster.properties.maintenance_window.time = subject_config[:maintenance_time]
      cluster.properties.api_subnet_allow_list = subject_config[:api_subnet_allow_list].split(',')
      cluster.properties.s3_buckets = subject_config[:s3_buckets].split(',').map { |el| Ionoscloud::S3Bucket.new(name: el) }

      expected_body = {
        name: subject_config[:name],
        k8sVersion: subject_config[:version],
        maintenanceWindow: {
          dayOfTheWeek: subject_config[:maintenance_day],
          time: subject_config[:maintenance_time],
        },
        apiSubnetAllowList: subject_config[:api_subnet_allow_list].split(','),
        s3Buckets: subject_config[:s3_buckets].split(',').map { |el| { name: el } },
      }

      expect(subject.api_client).not_to receive(:wait_for)
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
            method: 'PUT',
            path: "/k8s/#{cluster.id}",
            operation: :'KubernetesApi.k8s_put',
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
