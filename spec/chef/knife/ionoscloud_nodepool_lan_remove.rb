require 'spec_helper'
require 'ionoscloud_nodepool_lan_remove'

Chef::Knife::IonoscloudNodepoolLanRemove.load_deps

describe Chef::Knife::IonoscloudNodepoolLanRemove do
  before :each do
    subject { Chef::Knife::IonoscloudNodepoolLanRemove.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call KubernetesApi.k8s_nodepools_put to remove the lan when the ID is valid and the lan exists on the nodepool' do
      nodepool = k8s_nodepool_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        cluster_id: 'cluster_id',
        nodepool_id: nodepool.id,
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [nodepool.properties.lans.first.id]

      auto_scaling = "Min node count: #{nodepool.properties.auto_scaling.min_node_count}, Max node count:#{nodepool.properties.auto_scaling.max_node_count}"
      maintenance_window = "#{nodepool.properties.maintenance_window.day_of_the_week}, #{nodepool.properties.maintenance_window.time}"
      lans = [nodepool.properties.lans[1]].map { |lan| lan.to_hash }

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
      expect(subject).to receive(:puts).with("Public IPs: #{nodepool.properties.public_ips}")
      expect(subject).to receive(:puts).with("LANs: #{lans}")
      expect(subject).to receive(:puts).with("Availability Zone: #{nodepool.properties.availability_zone}")
      expect(subject).to receive(:puts).with("Auto Scaling: #{auto_scaling}")
      expect(subject).to receive(:puts).with("Maintenance Window: #{maintenance_window}")
      expect(subject).to receive(:puts).with("State: #{nodepool.metadata.state}")
      expect(subject.ui).to receive(:info).with("Removing Lans #{subject.name_args} from the Nodepoool.")

      expected_body = nodepool.properties.to_hash
      expected_body[:lans] = [expected_body[:lans][1]]
      expected_body.delete(:name)
      expected_body.delete(:datacenterId)
      expected_body.delete(:ramSize)
      expected_body.delete(:cpuFamily)
      expected_body.delete(:coresCount)
      expected_body.delete(:storageSize)
      expected_body.delete(:storageType)
      expected_body.delete(:availabilityZone)
      expected_body.delete(:availableUpgradeVersions)
      expected_body.delete(:labels)
      expected_body.delete(:annotations)

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
            body: { properties: expected_body },
            return_type: 'KubernetesNodePool',
            result: nodepool,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should call KubernetesApi.k8s_nodepools_put to remove the lan when the ID is valid but the lan does not exist on the nodepool' do
      nodepool = k8s_nodepool_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        cluster_id: 'cluster_id',
        nodepool_id: nodepool.id,
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [123]

      auto_scaling = "Min node count: #{nodepool.properties.auto_scaling.min_node_count}, Max node count:#{nodepool.properties.auto_scaling.max_node_count}"
      maintenance_window = "#{nodepool.properties.maintenance_window.day_of_the_week}, #{nodepool.properties.maintenance_window.time}"

      expect(subject.ui).to receive(:info).with("None of the specified Lan IDs (#{subject.name_args}) are present on the Nodepoool.")
      expect(subject).to receive(:puts).with("ID: #{nodepool.id}")
      expect(subject).to receive(:puts).with("Name: #{nodepool.properties.name}")
      expect(subject).to receive(:puts).with("K8s Version: #{nodepool.properties.k8s_version}")
      expect(subject).to receive(:puts).with("Node Count: #{nodepool.properties.node_count}")
      expect(subject).to receive(:puts).with("Lans: #{nodepool.properties.lans.map do
        |lan|
        {
          id: lan.id,
          dhcp: lan.dhcp,
          routes: lan.routes ? lan.routes.map do
            |route|
            {
              network: route.network,
              gateway_ip: route.gateway_ip,
            }
          end : []
        }
      end}")
      expect(subject).to receive(:puts).with("Auto Scaling: #{auto_scaling}")
      expect(subject).to receive(:puts).with("Maintenance Window: #{maintenance_window}")
      expect(subject).to receive(:puts).with("State: #{nodepool.metadata.state}")

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
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not call LoadBalancersApi.datacenters_loadbalancers_delete when the ID is not valid' do
      nodepool = k8s_nodepool_mock
      nic_id = 'invalid_id'
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        cluster_id: 'cluster_id',
        nodepool_id: 'nodepool_id',
        lan_id: 'lan_id',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject.ui).to receive(:error).with("Nodepool ID #{subject_config[:nodepool_id]} not found.")

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
            exception: Ionoscloud::ApiError.new(code: 404),
          },
        ],
      )

      expect { subject.run }.to raise_error(SystemExit) do |error|
        expect(error.status).to eq(1)
      end
    end

    it 'should not make any call if any required option is missing' do
      check_required_options(subject)
    end
  end
end
