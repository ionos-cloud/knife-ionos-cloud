require 'spec_helper'
require 'ionoscloud_dbaas_postgres_cluster_create'

Chef::Knife::IonoscloudDbaasPostgresClusterCreate.load_deps

describe Chef::Knife::IonoscloudDbaasPostgresClusterCreate do
  before :each do
    subject { Chef::Knife::IonoscloudDbaasPostgresClusterCreate.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call ClustersApi.cluster_post with the expected arguments and output based on what it receives' do
      cluster = cluster_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        cluster_id: 'cluster_id',
        display_name: cluster.properties.display_name,
        postgres_version: cluster.properties.postgres_version,
        location: cluster.properties.location,
        backup_location: cluster.properties.backup_location,
        instances: cluster.properties.instances,
        ram: cluster.properties.ram,
        cores: cluster.properties.cores,
        storage_size: cluster.properties.storage_size,
        storage_type: cluster.properties.storage_type,
        connections: cluster.properties.connections.map do |connection|
          {
            'datacenter_id' => connection.datacenter_id,
            'lan_id' => connection.lan_id,
            'cidr' => connection.cidr,
          }
        end,
        time: cluster.properties.maintenance_window.time,
        day_of_the_week: cluster.properties.maintenance_window.day_of_the_week,
        synchronization_mode: cluster.properties.synchronization_mode,
        state: cluster.metadata.state,
        username: 'usr',
        password: 'pass123',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{cluster.id}")
      expect(subject).to receive(:puts).with("Display Name: #{cluster.properties.display_name}")
      expect(subject).to receive(:puts).with("Postgres Version: #{cluster.properties.postgres_version}")
      expect(subject).to receive(:puts).with("Location: #{cluster.properties.location}")
      expect(subject).to receive(:puts).with("Backup location: #{cluster.properties.backup_location}")
      expect(subject).to receive(:puts).with("Instances: #{cluster.properties.instances}")
      expect(subject).to receive(:puts).with("RAM Size: #{cluster.properties.ram}")
      expect(subject).to receive(:puts).with("Cores: #{cluster.properties.cores}")
      expect(subject).to receive(:puts).with("Storage Size: #{cluster.properties.storage_size}")
      expect(subject).to receive(:puts).with("Storage Type: #{cluster.properties.storage_type}")
      expect(subject).to receive(:puts).with("Connections: #{cluster.properties.connections.map { |connection| connection.to_hash }}")
      expect(subject).to receive(:puts).with("Maintenance Window: #{cluster.properties.maintenance_window.to_hash}")
      expect(subject).to receive(:puts).with("Synchronization Mode: #{cluster.properties.synchronization_mode}")
      expect(subject).to receive(:puts).with("Lifecycle Status: #{cluster.metadata.state}")

      expected_body = cluster.properties.to_hash
      expected_body[:credentials] = { username: subject_config[:username], password: subject_config[:password] }
      expected_body[:fromBackup] = {}

      mock_dbaas_call_api(
        subject,
        [
          {
            method: 'POST',
            path: '/clusters',
            operation: :'ClustersApi.clusters_post',
            return_type: 'ClusterResponse',
            body: { properties: expected_body },
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
        expect(subject.api_client_dbaas).not_to receive(:call_api)

        expect { subject.run }.to raise_error(SystemExit) do |error|
          expect(error.status).to eq(1)
        end

        required_options.each { |value| subject.config[value] = nil }
      end
    end
  end
end
