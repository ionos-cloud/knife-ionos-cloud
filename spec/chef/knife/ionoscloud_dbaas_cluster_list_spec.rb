require 'spec_helper'
require 'ionoscloud_dbaas_cluster_list'

Chef::Knife::IonoscloudDbaasClusterList.load_deps

describe Chef::Knife::IonoscloudDbaasClusterList do
  before :each do
    subject { Chef::Knife::IonoscloudDbaasClusterList.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call ClustersApi.clusters_get' do
      clusters = clusters_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      cluster_list = [
        subject.ui.color('ID', :bold),
        subject.ui.color('Display Name', :bold),
        subject.ui.color('Postgres Version', :bold),
        subject.ui.color('Location', :bold),
        subject.ui.color('Instances', :bold),
        subject.ui.color('Cores', :bold),
        subject.ui.color('RAM Size', :bold),
        subject.ui.color('Storage Size', :bold),
        subject.ui.color('Storage Type', :bold),
        subject.ui.color('Connections', :bold),
        subject.ui.color('Maintenance Window', :bold),
        subject.ui.color('Synchronization Mode', :bold),
        subject.ui.color('Lifecycle Status', :bold),
      ]

      clusters.items.each do |cluster|
        cluster_list << cluster.id
        cluster_list << cluster.properties.display_name
        cluster_list << cluster.properties.postgres_version
        cluster_list << cluster.properties.location
        cluster_list << cluster.properties.instances
        cluster_list << cluster.properties.cores
        cluster_list << cluster.properties.ram
        cluster_list << cluster.properties.storage_size
        cluster_list << cluster.properties.storage_type
        cluster_list << cluster.properties.connections
        cluster_list << cluster.properties.maintenance_window
        cluster_list << cluster.properties.synchronization_mode
        cluster_list << cluster.metadata.state
      end

      expect(subject.ui).to receive(:list).with(cluster_list, :uneven_columns_across, 13)

      mock_dbaas_call_api(
        subject,
        [
          {
            method: 'GET',
            path: '/clusters',
            operation: :'ClustersApi.clusters_get',
            return_type: 'ClusterList',
            result: clusters,
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