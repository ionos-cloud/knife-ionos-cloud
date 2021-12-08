require 'spec_helper'
require 'ionoscloud_dbaas_cluster_update'

Chef::Knife::IonoscloudDbaasClusterUpdate.load_deps

describe Chef::Knife::IonoscloudDbaasClusterUpdate do
  before :each do
    subject { Chef::Knife::IonoscloudDbaasClusterUpdate.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call ClustersApi.clusters_patch' do
      cluster = cluster_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        cluster_id: cluster.id,
        name: cluster.name + '_edited',
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{cluster.id}")
      expect(subject).to receive(:puts).with("Display Name: #{cluster.display_name}")
      expect(subject).to receive(:puts).with("Postgres Version: #{cluster.postgres_version}")
      expect(subject).to receive(:puts).with("Location: #{cluster.location}")
      expect(subject).to receive(:puts).with("Replicas: #{dcluster.replicas}")
      expect(subject).to receive(:puts).with("RAM Size: #{cluster.ram_size}")
      expect(subject).to receive(:puts).with("CPU Core Count: #{cluster.cpu_core_count}")
      expect(subject).to receive(:puts).with("Storage Size: #{dcluster.storage_size}")
      expect(subject).to receive(:puts).with("Storage Type: #{cluster.storage_type}")
      expect(subject).to receive(:puts).with("Backup Enabled: #{cluster.backup_enabled}")
      expect(subject).to receive(:puts).with("VDC Connections: #{cluster.vdc_connections}")
      expect(subject).to receive(:puts).with("Maintenance Window: #{cluster.maintenance_window}")
      expect(subject).to receive(:puts).with("Lifecycle Status: #{cluster.lifecycle_status}")
      expect(subject).to receive(:puts).with("Synchronization Mode: #{cluster.synchronization_mode}")

      datacenter.properties.name = subject_config[:name]

      mock_wait_for(subject)    # aici
      mock_call_api(    # aici ar trebui sa fie mock_dbaas_call_api???
        subject,
        [
          {
            method: 'PATCH',
            path: "/clusters/#{cluster.id}",
            operation: :'ClustersApi.clusters_patch_with_http_info',
            return_type: 'Cluster',
            body: { name: subject_config[:name] },
            result: cluster,
          },
          {
            method: 'GET',
            path: "/clusters/#{cluster.id}",
            operation: :'ClustersApi.clusters_find_by_id',
            return_type: 'Cluster',
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
          expect(subject.api_client).not_to receive(:call_api)    # todo in loc de call_api e call_api_dbaas?????
  
          expect { subject.run }.to raise_error(SystemExit) do |error|
            expect(error.status).to eq(1)
          end
  
          required_options.each { |value| subject.config[value] = nil }
        end
      end
    end
  end
  