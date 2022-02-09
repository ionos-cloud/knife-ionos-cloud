require 'spec_helper'
require 'ionoscloud_datacenter_update'

Chef::Knife::IonoscloudDatacenterUpdate.load_deps

describe Chef::Knife::IonoscloudDatacenterUpdate do
  before :each do
    subject { Chef::Knife::IonoscloudDatacenterUpdate.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call DataCentersApi.datacenters_patch' do
      datacenter = datacenter_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: datacenter.id,
        name: datacenter.properties.name + '_edited',
        description: datacenter.properties.description + '_edited',
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{datacenter.id}")
      expect(subject).to receive(:puts).with("Name: #{subject_config[:name]}")
      expect(subject).to receive(:puts).with("Description: #{subject_config[:description]}")
      expect(subject).to receive(:puts).with("Location: #{datacenter.properties.location}")
      expect(subject).to receive(:puts).with("Version: #{datacenter.properties.version}")
      expect(subject).to receive(:puts).with("Features: #{datacenter.properties.features}")
      expect(subject).to receive(:puts).with("Sec Auth Protection: #{datacenter.properties.sec_auth_protection}")

      datacenter.properties.name = subject_config[:name]
      datacenter.properties.description = subject_config[:description]

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'PATCH',
            path: "/datacenters/#{datacenter.id}",
            operation: :'DataCentersApi.datacenters_patch',
            return_type: 'Datacenter',
            body: { name: subject_config[:name], description: subject_config[:description] },
            result: datacenter,
          },
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
