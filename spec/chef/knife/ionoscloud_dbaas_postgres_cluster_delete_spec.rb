require 'spec_helper'
require 'ionoscloud_dbaas_postgres_cluster_delete'

Chef::Knife::IonoscloudDbaasPostgresClusterDelete.load_deps

describe Chef::Knife::IonoscloudDbaasPostgresClusterDelete do
  before :each do
    subject { Chef::Knife::IonoscloudDbaasPostgresClusterDelete.new }

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
      expect(subject).to receive(:puts).with("Display Name: #{cluster.properties.display_name}")
      expect(subject).to receive(:puts).with("Postgres Version: #{cluster.properties.postgres_version}")
      expect(subject).to receive(:puts).with("Location: #{cluster.properties.location}")
      expect(subject).to receive(:puts).with("Instances: #{cluster.properties.instances}")
      expect(subject).to receive(:puts).with("RAM Size: #{cluster.properties.ram}")
      expect(subject).to receive(:puts).with("Cores: #{cluster.properties.cores}")
      expect(subject).to receive(:puts).with("Storage Size: #{cluster.properties.storage_size}")
      expect(subject).to receive(:puts).with("Storage Type: #{cluster.properties.storage_type}")
      expect(subject).to receive(:puts).with("Connections: #{cluster.properties.connections.map { |connection| connection.to_hash }}")
      expect(subject).to receive(:puts).with("Maintenance Window: #{cluster.properties.maintenance_window.to_hash}")
      expect(subject).to receive(:puts).with("Synchronization Mode: #{cluster.properties.synchronization_mode}")
      expect(subject).to receive(:puts).with("Lifecycle Status: #{cluster.metadata.state}")
      expect(subject.ui).to receive(:warn).with("Deleted Cluster #{cluster.id}.")

      mock_dbaas_postgres_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/clusters/#{cluster.id}",
            operation: :'ClustersApi.clusters_find_by_id',
            return_type: 'ClusterResponse',
            result: cluster,
          },
          {
            method: 'DELETE',
            path: "/clusters/#{cluster.id}",
            operation: :'ClustersApi.clusters_delete',
            return_type: 'ClusterResponse',
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

      mock_dbaas_postgres_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/clusters/#{cluster_id}",
            operation: :'ClustersApi.clusters_find_by_id',
            return_type: 'ClusterResponse',
            exception: IonoscloudDbaasPostgres::ApiError.new(code: 404),
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
