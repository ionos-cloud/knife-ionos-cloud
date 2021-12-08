require 'spec_helper'
require 'ionoscloud_dbaas_cluster_delete'

Chef::Knife::IonoscloudDbaasClusterDelete.load_deps

describe Chef::Knife::IonoscloudDbaasClusterDelete do
  before :each do
    subject { Chef::Knife::IonoscloudDbaasClusterDelete.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call ClustersApi.clusters_delete when the ID is valid' do
      cluster = cluster_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [cluster.id]

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
      expect(subject.ui).to receive(:warn).with("Deleted Cluster #{cluster.id}. Request ID: ")

      expect(subject.api_client).not_to receive(:wait_for)
      expect(subject).to receive(:get_request_id).once
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/clusters/#{cluster.id}",
            operation: :'ClustersApi.clusters_find_by_id',
            return_type: 'Datacenter',
            result: cluster,
          },
          {
            method: 'DELETE',
            path: "/clusters/#{cluster.id}",
            operation: :'ClustersApi.clusters_delete_with_http_info',
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not call ClustersApi.clusters_delete when the user ID is not valid' do
        cluster_id = 'invalid_id'
        subject_config = {
          ionoscloud_username: 'email',
          ionoscloud_password: 'password',
        }
  
        subject_config.each { |key, value| subject.config[key] = value }
        subject.name_args = [cluster_id]
  
        expect(subject.ui).to receive(:error).with("Cluster ID #{cluster_id} not found. Skipping.")
  
        expect(subject.api_client).not_to receive(:wait_for)   # todo in loc de call_api e call_api_dbaas?????S
        mock_call_api(
          subject,
          [
            {
              method: 'GET',
              path: "/clusters/#{cluster_id}",
              operation: :'ClustersApi.clusters_find_by_id',
              return_type: 'Cluster',
              exception: Ionoscloud::ApiError.new(code: 404),   #trebuie ionoscloudDbass::Error sau ce eroare o fii prin el?
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
          expect(subject.api_client).not_to receive(:call_api)     # todo in loc de call_api e call_api_dbaas?????
  
          expect { subject.run }.to raise_error(SystemExit) do |error|
            expect(error.status).to eq(1)
          end
  
          required_options.each { |value| subject.config[value] = nil }
        end
      end
    end
  end
  