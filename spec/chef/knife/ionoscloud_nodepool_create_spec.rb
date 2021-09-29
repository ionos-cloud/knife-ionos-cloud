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
        version: nodepool.properties.k8s_version,
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
        labels: nodepool.properties.labels,
        annotations: nodepool.properties.annotations,
        lans: nodepool.properties.lans.map { |lan| lan.id }.join(','),
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expected_body = nodepool.properties.to_hash
      expected_body[:lans].map! { |lan| lan.delete(:dhcp); lan.delete(:routes); lan[:id] = Integer(lan[:id]); lan }
      expected_body.delete(:publicIps)
      expected_body.delete(:availableUpgradeVersions)

      auto_scaling = "Min node count: #{nodepool.properties.auto_scaling.min_node_count}, Max node count:#{nodepool.properties.auto_scaling.max_node_count}"
      maintenance_window = "#{nodepool.properties.maintenance_window.day_of_the_week}, #{nodepool.properties.maintenance_window.time}"

      expect(subject).to receive(:puts).with("ID: #{nodepool.id}")
      expect(subject).to receive(:puts).with("Name: #{nodepool.properties.name}")
      expect(subject).to receive(:puts).with("K8s Version: #{nodepool.properties.k8s_version}")
      expect(subject).to receive(:puts).with("Datacenter ID: #{nodepool.properties.datacenter_id}")
      expect(subject).to receive(:puts).with("Node Count: #{nodepool.properties.node_count}")
      expect(subject).to receive(:puts).with("CPU Family: #{nodepool.properties.cpu_family}")
      expect(subject).to receive(:puts).with("Cores Count: #{nodepool.properties.cores_count}")
      expect(subject).to receive(:puts).with("RAM: #{nodepool.properties.ram_size}")
      expect(subject).to receive(:puts).with("Storage Type: #{nodepool.properties.storage_type}")
      expect(subject).to receive(:puts).with("Storage Size: #{nodepool.properties.storage_size}")
      expect(subject).to receive(:puts).with("Labels: #{nodepool.properties.labels}")
      expect(subject).to receive(:puts).with("Annotations: #{nodepool.properties.annotations}")
      expect(subject).to receive(:puts).with("LANs: #{nodepool.properties.lans.map { |lan| lan.to_hash }}")
      expect(subject).to receive(:puts).with("Availability Zone: #{nodepool.properties.availability_zone}")
      expect(subject).to receive(:puts).with("Auto Scaling: #{auto_scaling}")
      expect(subject).to receive(:puts).with("Maintenance Window: #{maintenance_window}")
      expect(subject).to receive(:puts).with("State: #{nodepool.metadata.state}")

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
