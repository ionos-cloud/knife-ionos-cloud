require 'spec_helper'
require 'ionoscloud_dbaas_postgres_version_list'

Chef::Knife::IonoscloudDbaasPostgresVersionList.load_deps

describe Chef::Knife::IonoscloudDbaasPostgresVersionList do
  before :each do
    subject { Chef::Knife::IonoscloudDbaasPostgresVersionList.new }

    @postgres_versions = postgres_version_list_mock

    @postgres_version_list = [
      subject.ui.color('Version', :bold),
      @postgres_versions.data.first.name,
      @postgres_versions.data[1].name,
    ]

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call ClustersApi.postgres_versions_get when no cluster_id is set' do
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject.ui).to receive(:list).with(@postgres_version_list, :uneven_columns_across, 1)

      mock_dbaas_call_api(
        subject,
        [
          {
            method: 'GET',
            path: '/clusters/postgresversions',
            operation: :'ClustersApi.postgres_versions_get',
            return_type: 'PostgresVersionList',
            result: @postgres_versions,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should call ClustersApi.cluster_postgres_versions_get when cluster_id is set' do
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        cluster_id: 'cluster_id',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject.ui).to receive(:list).with(@postgres_version_list, :uneven_columns_across, 1)

      mock_dbaas_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/clusters/#{subject_config[:cluster_id]}/postgresversions",
            operation: :'ClustersApi.cluster_postgres_versions_get',
            return_type: 'PostgresVersionList',
            result: @postgres_versions,
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
