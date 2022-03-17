require 'spec_helper'
require 'ionoscloud_dbaas_postgres_cluster_get'

Chef::Knife::IonoscloudDbaasPostgresClusterGet.load_deps

describe Chef::Knife::IonoscloudDbaasPostgresClusterGet do
  before :each do
    subject { Chef::Knife::IonoscloudDbaasPostgresClusterGet.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call ClustersApi.clusters_find_by_id' do
      cluster = cluster_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        cluster_id: cluster.id,
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

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
      expect(subject).to receive(:puts).with("Maintenance Window: #{cluster.properties.maintenance_window}")
      expect(subject).to receive(:puts).with("Synchronization Mode: #{cluster.properties.synchronization_mode}")
      expect(subject).to receive(:puts).with("Lifecycle Status: #{cluster.metadata.state}")

      mock_dbaas_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/clusters/#{cluster.id}",
            operation: :'ClustersApi.clusters_find_by_id',
            return_type: 'ClusterResponse',
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
