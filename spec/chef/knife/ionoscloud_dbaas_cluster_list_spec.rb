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
        subject.ui.color('Replicas', :bold),
        subject.ui.color('RAM Size', :bold),
        subject.ui.color('CPU Core Count', :bold),
        subject.ui.color('Storage Size', :bold),
        subject.ui.color('Storage Type', :bold),
        subject.ui.color('Backup Enabled', :bold),
        subject.ui.color('VDC Connections', :bold),
        subject.ui.color('Maintenance Window', :bold),
        subject.ui.color('Lifecycle Status', :bold),
        subject.ui.color('Synchronization Mode', :bold),
      ]

      clusters.items.each do |cluster|
        cluster_list << cluster.id
        cluster_list << cluster.display_name
        cluster_list << cluster.postgres_version
        cluster_list << cluster.location
        cluster_list << cluster.replicas
        cluster_list << cluster.ram_size
        cluster_list << cluster.cpu_core_count
        cluster_list << cluster.storage_size
        cluster_list << cluster.storage_type
        cluster_list << cluster.backup_enabled
        cluster_list << cluster.vdc_connections
        cluster_list << cluster.maintenance_window
        cluster_list << cluster.lifecycle_status
        cluster_list << cluster.synchronization_mode
      end

      expect(subject.ui).to receive(:list).with(cluster_list, :uneven_columns_across, 14)

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: '/clusters',
            operation: :'ClustersApi.clusters_get',
            return_type: 'Clusters',
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
        expect(subject.api_client).not_to receive(:call_api)    # todo in loc de call_api e call_api_dbaas?????

        expect { subject.run }.to raise_error(SystemExit) do |error|
          expect(error.status).to eq(1)
        end

        required_options.each { |value| subject.config[value] = nil }
      end
    end
  end
end