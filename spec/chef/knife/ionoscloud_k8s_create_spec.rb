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
      }
 
      subject_config.each { |key, value| subject.config[key] = value }

      maintenance_window = "#{cluster.properties.maintenance_window.day_of_the_week}, #{cluster.properties.maintenance_window.time}"

      expect(subject).to receive(:puts).with("ID: #{cluster.id}")
      expect(subject).to receive(:puts).with("Name: #{cluster.properties.name}")
      expect(subject).to receive(:puts).with("k8s Version: #{cluster.properties.k8s_version}")
      expect(subject).to receive(:puts).with("Maintenance Window: #{maintenance_window}")
      expect(subject).to receive(:puts).with("State: #{cluster.metadata.state}")

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
      subject.run
    #   expect { subject.run }.not_to raise_error(Exception)
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
