require 'spec_helper'
require 'ionoscloud_nodepool_update'

Chef::Knife::IonoscloudNodepoolUpdate.load_deps

describe Chef::Knife::IonoscloudNodepoolUpdate do
  before :each do
    subject { Chef::Knife::IonoscloudNodepoolUpdate.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call KubernetesApi.k8s_nodepools_put' do
      nodepool = k8s_nodepool_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        cluster_id: 'cluster_id',
        nodepool_id: nodepool.id,
        k8s_version: '18.18.18',
        node_count: nodepool.properties.node_count + 1,
        public_ips: '127.1.1.1,127.2.2.2,127.3.3.3',
        lans: '13',
        maintenance_day: 'Tuesday',
        maintenance_time: '03:48:30Z',
        max_node_count: nodepool.properties.auto_scaling.max_node_count + 1,
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      auto_scaling = "Min node count: #{nodepool.properties.auto_scaling.min_node_count}, Max node count:#{subject_config[:max_node_count]}"
      maintenance_window = "#{subject_config[:maintenance_day]}, #{subject_config[:maintenance_time]}"
      lans = subject_config[:lans].split(',').map { |lan| { id: lan } }

      expect(subject).to receive(:puts).with("ID: #{nodepool.id}")
      expect(subject).to receive(:puts).with("Name: #{nodepool.properties.name}")
      expect(subject).to receive(:puts).with("K8s Version: #{subject_config[:k8s_version]}")
      expect(subject).to receive(:puts).with("Datacenter ID: #{nodepool.properties.datacenter_id}")
      expect(subject).to receive(:puts).with("Node Count: #{subject_config[:node_count]}")
      expect(subject).to receive(:puts).with("CPU Family: #{nodepool.properties.cpu_family}")
      expect(subject).to receive(:puts).with("Cores Count: #{nodepool.properties.cores_count}")
      expect(subject).to receive(:puts).with("RAM: #{nodepool.properties.ram_size}")
      expect(subject).to receive(:puts).with("Storage Type: #{nodepool.properties.storage_type}")
      expect(subject).to receive(:puts).with("Storage Size: #{nodepool.properties.storage_size}")
      expect(subject).to receive(:puts).with("Public IPs: #{subject_config[:public_ips].split(',')}")
      expect(subject).to receive(:puts).with("LANs: #{lans}")
      expect(subject).to receive(:puts).with("Availability Zone: #{nodepool.properties.availability_zone}")
      expect(subject).to receive(:puts).with("Auto Scaling: #{auto_scaling}")
      expect(subject).to receive(:puts).with("Maintenance Window: #{maintenance_window}")
      expect(subject).to receive(:puts).with("State: #{nodepool.metadata.state}")

      nodepool.properties.k8s_version = subject_config[:k8s_version]
      nodepool.properties.node_count = subject_config[:node_count]
      nodepool.properties.public_ips = subject_config[:public_ips].split(',')
      nodepool.properties.lans = subject_config[:lans].split(',').map { |lan| Ionoscloud::KubernetesNodePoolLan.new(id: lan) }
      nodepool.properties.maintenance_window.day_of_the_week = subject_config[:maintenance_day]
      nodepool.properties.maintenance_window.time = subject_config[:maintenance_time]
      nodepool.properties.auto_scaling.max_node_count = subject_config[:max_node_count]

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/k8s/#{subject_config[:cluster_id]}/nodepools/#{subject_config[:nodepool_id]}",
            operation: :'KubernetesApi.k8s_nodepools_find_by_id',
            return_type: 'KubernetesNodePool',
            result: nodepool,
          },
          {
            method: 'PUT',
            path: "/k8s/#{subject_config[:cluster_id]}/nodepools/#{subject_config[:nodepool_id]}",
            operation: :'KubernetesApi.k8s_nodepools_put',
            return_type: 'KubernetesNodePool',
            body: {
              properties: {
                k8sVersion: subject_config[:k8s_version],
                nodeCount: subject_config[:node_count],
                publicIps: subject_config[:public_ips].split(','),
                labels: nodepool.properties.labels,
                annotations: nodepool.properties.annotations,
                lans: subject_config[:lans].split(',').map { |lan| { id: Integer(lan) } },
                maintenanceWindow: {
                  dayOfTheWeek: subject_config[:maintenance_day],
                  time: subject_config[:maintenance_time],
                },
                autoScaling: {
                  minNodeCount: nodepool.properties.auto_scaling.min_node_count,
                  maxNodeCount: subject_config[:max_node_count],
                },
              },
            },
            result: nodepool,
          },
          {
            method: 'GET',
            path: "/k8s/#{subject_config[:cluster_id]}/nodepools/#{subject_config[:nodepool_id]}",
            operation: :'KubernetesApi.k8s_nodepools_find_by_id',
            return_type: 'KubernetesNodePool',
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
