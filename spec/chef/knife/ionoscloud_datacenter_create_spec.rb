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
    it 'should call DataCentersApi.datacenters_post with the expected arguments and output based on what it receives' do
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
      expected_body.delete(:cpuArchitecture)

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'POST',
            path: '/datacenters',
            operation: :'DataCentersApi.datacenters_post',
            return_type: 'Datacenter',
            body: { properties: expected_body },
            result: datacenter,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not make any call if any required option is missing' do
      check_required_options(subject)
    end
  end
end
