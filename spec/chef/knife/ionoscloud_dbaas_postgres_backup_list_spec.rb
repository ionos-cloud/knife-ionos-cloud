require 'spec_helper'
require 'ionoscloud_dbaas_postgres_backup_list'

Chef::Knife::IonoscloudDbaasPostgresBackupList.load_deps

describe Chef::Knife::IonoscloudDbaasPostgresBackupList do
  before :each do
    subject { Chef::Knife::IonoscloudDbaasPostgresBackupList.new }

    @cluster_backups = cluster_backups_mock

    @cluster_backup_list = [
      subject.ui.color('ID', :bold),
      subject.ui.color('Type', :bold),
      subject.ui.color('Cluster ID', :bold),
      subject.ui.color('Is Active', :bold),
      subject.ui.color('Earliest Recovery Target Time', :bold),
      subject.ui.color('Created Date', :bold),

      @cluster_backups.items.first.id,
      @cluster_backups.items.first.type,
      @cluster_backups.items.first.properties.cluster_id,
      @cluster_backups.items.first.properties.is_active,
      @cluster_backups.items.first.properties.earliest_recovery_target_time,
      @cluster_backups.items.first.metadata.created_date,

      @cluster_backups.items[1].id,
      @cluster_backups.items[1].type,
      @cluster_backups.items[1].properties.cluster_id,
      @cluster_backups.items[1].properties.is_active,
      @cluster_backups.items[1].properties.earliest_recovery_target_time,
      @cluster_backups.items[1].metadata.created_date,
    ]

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call BackupsApi.clusters_backups_get when no cluster_id is set' do
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject.ui).to receive(:list).with(@cluster_backup_list, :uneven_columns_across, 6)

      mock_dbaas_call_api(
        subject,
        [
          {
            method: 'GET',
            path: '/clusters/backups',
            operation: :'BackupsApi.clusters_backups_get',
            return_type: 'ClusterBackupList',
            result: @cluster_backups,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should call BackupsApi.cluster_backups_get when cluster_id is set' do
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        cluster_id: 'cluster_id',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject.ui).to receive(:list).with(@cluster_backup_list, :uneven_columns_across, 6)

      mock_dbaas_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/clusters/#{subject_config[:cluster_id]}/backups",
            operation: :'BackupsApi.cluster_backups_get',
            return_type: 'ClusterBackupList',
            result: @cluster_backups,
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
