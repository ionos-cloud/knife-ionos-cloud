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
        display_name: cluster.properties.display_name + '_edited',
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{cluster.id}")
      expect(subject).to receive(:puts).with("Display Name: #{subject_config[:display_name]}")
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

      expected_body = cluster.properties.to_hash.merge({ #  sterge expected_body
        display_name: subject_config[:display_name],
      })

      expected_body2 = {
        displayName: subject_config[:display_name],
      }

      cluster.properties.display_name = subject_config[:display_name]

      mock_dbaas_call_api(
        subject,
        [
          {
            method: 'PATCH',
            path: "/clusters/#{cluster.id}",
            operation: :'ClustersApi.clusters_patch',
            return_type: 'ClusterResponse',
            body: { properties: expected_body2 }, # properties: expected_body    sau    display_name: subject_config[:display_name]     SI INTREABA-L PE RADU DACA E OK ASA CU expected body
            result: cluster,
          },
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
  