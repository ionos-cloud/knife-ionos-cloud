require 'spec_helper'
require 'ionoscloud_datacenter_get'

Chef::Knife::IonoscloudDatacenterGet.load_deps

describe Chef::Knife::IonoscloudDatacenterGet do
  before :each do
    subject { Chef::Knife::IonoscloudDatacenterGet.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call DataCentersApi.datacenters_find_by_id' do
      datacenter = datacenter_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: datacenter.id,
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{datacenter.id}")
      expect(subject).to receive(:puts).with("Name: #{datacenter.properties.name}")
      expect(subject).to receive(:puts).with("Description: #{datacenter.properties.description}")
      expect(subject).to receive(:puts).with("Location: #{datacenter.properties.location}")
      expect(subject).to receive(:puts).with("Version: #{datacenter.properties.version}")
      expect(subject).to receive(:puts).with("Features: #{datacenter.properties.features}")
      expect(subject).to receive(:puts).with("Sec Auth Protection: #{datacenter.properties.sec_auth_protection}")

      expect(subject.api_client).not_to receive(:wait_for)
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
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not make any call if any required option is missing' do
      check_required_options(subject)
    end
  end
end
