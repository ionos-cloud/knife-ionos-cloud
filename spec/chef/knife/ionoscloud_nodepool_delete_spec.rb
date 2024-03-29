require 'spec_helper'
require 'ionoscloud_nodepool_delete'

Chef::Knife::IonoscloudNodepoolDelete.load_deps

describe Chef::Knife::IonoscloudNodepoolDelete do
  before :each do
    subject { Chef::Knife::IonoscloudNodepoolDelete.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call KubernetesApi.k8s_nodepools_delete when the ID is valid' do
      k8s_nodepool = k8s_nodepool_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        cluster_id: 'cluster_id',
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [k8s_nodepool.id]

      auto_scaling = "Min node count: #{k8s_nodepool.properties.auto_scaling.min_node_count}, Max node count:#{k8s_nodepool.properties.auto_scaling.max_node_count}"
      maintenance_window = "#{k8s_nodepool.properties.maintenance_window.day_of_the_week}, #{k8s_nodepool.properties.maintenance_window.time}"

      expect(subject).to receive(:puts).with("ID: #{k8s_nodepool.id}")
      expect(subject).to receive(:puts).with("Name: #{k8s_nodepool.properties.name}")
      expect(subject).to receive(:puts).with("K8s Version: #{k8s_nodepool.properties.k8s_version}")
      expect(subject).to receive(:puts).with("Datacenter ID: #{k8s_nodepool.properties.datacenter_id}")
      expect(subject).to receive(:puts).with("Node Count: #{k8s_nodepool.properties.node_count}")
      expect(subject).to receive(:puts).with("CPU Family: #{k8s_nodepool.properties.cpu_family}")
      expect(subject).to receive(:puts).with("Cores Count: #{k8s_nodepool.properties.cores_count}")
      expect(subject).to receive(:puts).with("RAM: #{k8s_nodepool.properties.ram_size}")
      expect(subject).to receive(:puts).with("Storage Type: #{k8s_nodepool.properties.storage_type}")
      expect(subject).to receive(:puts).with("Storage Size: #{k8s_nodepool.properties.storage_size}")
      expect(subject).to receive(:puts).with("Public IPs: #{k8s_nodepool.properties.public_ips}")
      expect(subject).to receive(:puts).with("Labels: #{k8s_nodepool.properties.labels}")
      expect(subject).to receive(:puts).with("Annotations: #{k8s_nodepool.properties.annotations}")
      expect(subject).to receive(:puts).with("LANs: #{k8s_nodepool.properties.lans.map { |lan| lan.to_hash }}")
      expect(subject).to receive(:puts).with("Availability Zone: #{k8s_nodepool.properties.availability_zone}")
      expect(subject).to receive(:puts).with("Auto Scaling: #{auto_scaling}")
      expect(subject).to receive(:puts).with("Maintenance Window: #{maintenance_window}")
      expect(subject).to receive(:puts).with("State: #{k8s_nodepool.metadata.state}")
      expect(subject.ui).to receive(:warn).with("Deleted K8s Nodepool #{k8s_nodepool.id}.")

      expect(subject.api_client).not_to receive(:wait_for)
      expect(subject).not_to receive(:get_request_id)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/k8s/#{subject_config[:cluster_id]}/nodepools/#{k8s_nodepool.id}",
            operation: :'KubernetesApi.k8s_nodepools_find_by_id',
            return_type: 'KubernetesNodePool',
            result: k8s_nodepool,
          },
          {
            method: 'DELETE',
            path: "/k8s/#{subject_config[:cluster_id]}/nodepools/#{k8s_nodepool.id}",
            operation: :'KubernetesApi.k8s_nodepools_delete',
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not call KubernetesApi.k8s_nodepools_delete when the ID is not valid' do
      k8s_nodepool_id = 'invalid_id'
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        cluster_id: 'cluster_id',
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [k8s_nodepool_id]

      expect(subject.ui).to receive(:error).with("K8s Nodepool ID #{k8s_nodepool_id} not found. Skipping.")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/k8s/#{subject_config[:cluster_id]}/nodepools/#{k8s_nodepool_id}",
            operation: :'KubernetesApi.k8s_nodepools_find_by_id',
            return_type: 'KubernetesNodePool',
            exception: Ionoscloud::ApiError.new(code: 404),
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
