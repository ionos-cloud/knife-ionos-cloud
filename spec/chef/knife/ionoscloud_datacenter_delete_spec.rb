require 'spec_helper'
require 'ionoscloud_datacenter_delete'

Chef::Knife::IonoscloudDatacenterDelete.load_deps

describe Chef::Knife::IonoscloudDatacenterDelete do
  before :each do
    subject { Chef::Knife::IonoscloudDatacenterDelete.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call DataCentersApi.datacenters_delete when the ID is valid' do
      datacenter = datacenter_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [datacenter.id]

      expect(subject).to receive(:puts).with("ID: #{datacenter.id}")
      expect(subject).to receive(:puts).with("Name: #{datacenter.properties.name}")
      expect(subject).to receive(:puts).with("Description: #{datacenter.properties.description}")
      expect(subject).to receive(:puts).with("Location: #{datacenter.properties.location}")
      expect(subject).to receive(:puts).with("Version: #{datacenter.properties.version}")
      expect(subject).to receive(:puts).with("Features: #{datacenter.properties.features}")
      expect(subject).to receive(:puts).with("Sec Auth Protection: #{datacenter.properties.sec_auth_protection}")
      expect(subject.ui).to receive(:warn).with("Deleted Data center #{datacenter.id}. Request ID: ")

      expect(subject.api_client).not_to receive(:wait_for)
      expect(subject).to receive(:get_request_id).once
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{datacenter.id}",
            operation: :'DataCentersApi.datacenters_find_by_id',
            return_type: 'Datacenter',
            result: datacenter,
          },
          {
            method: 'DELETE',
            path: "/datacenters/#{datacenter.id}",
            operation: :'DataCentersApi.datacenters_delete',
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not call DataCentersApi.datacenters_delete when the user ID is not valid' do
      datacenter_id = 'invalid_id'
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [datacenter_id]

      expect(subject.ui).to receive(:error).with("Data center ID #{datacenter_id} not found. Skipping.")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{datacenter_id}",
            operation: :'DataCentersApi.datacenters_find_by_id',
            return_type: 'Datacenter',
            exception: Ionoscloud::ApiError.new(code: 404),
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
