require 'spec_helper'
require 'ionoscloud_datacenter_create'

Chef::Knife::IonoscloudDatacenterCreate.load_deps

describe Chef::Knife::IonoscloudDatacenterCreate do
  before :each do
    subject { Chef::Knife::IonoscloudDatacenterCreate.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call DataCenterApi.datacenters_post with the expected arguments and output based on what it receives' do
      datacenter = datacenter_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        name: datacenter.properties.name,
        description: datacenter.properties.description,
        location: datacenter.properties.location,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{datacenter.id}")
      expect(subject).to receive(:puts).with("Name: #{datacenter.properties.name}")
      expect(subject).to receive(:puts).with("Description: #{datacenter.properties.description}")
      expect(subject).to receive(:puts).with("Location: #{datacenter.properties.location}")
      expect(subject).to receive(:puts).with("Version: #{datacenter.properties.version}")
      expect(subject).to receive(:puts).with("Features: #{datacenter.properties.features}")
      expect(subject).to receive(:puts).with("Sec Auth Protection: #{datacenter.properties.sec_auth_protection}")

      expected_body = datacenter.properties.to_hash
      expected_body.delete(:version)

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'POST',
            path: '/datacenters',
            operation: :'DataCenterApi.datacenters_post',
            return_type: 'Datacenter',
            body: { properties: expected_body },
            result: datacenter,
          },
          {
            method: 'GET',
            path: "/datacenters/#{datacenter.id}",
            operation: :'DataCenterApi.datacenters_find_by_id',
            return_type: 'Datacenter',
            result: datacenter,
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
