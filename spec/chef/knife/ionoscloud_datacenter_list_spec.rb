require 'spec_helper'
require 'ionoscloud_datacenter_list'

Chef::Knife::IonoscloudDatacenterList.load_deps

describe Chef::Knife::IonoscloudDatacenterList do
  before :each do
    subject { Chef::Knife::IonoscloudDatacenterList.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call DataCenterApi.datacenters_get' do
      datacenters = datacenters_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      datacenter_list = [
        subject.ui.color('ID', :bold),
        subject.ui.color('Name', :bold),
        subject.ui.color('Description', :bold),
        subject.ui.color('Location', :bold),
        subject.ui.color('Version', :bold),
        subject.ui.color('Sec Auth Protection', :bold),
      ]

      datacenters.items.each do |datacenter|
        datacenter_list << datacenter.id
        datacenter_list << datacenter.properties.name
        datacenter_list << datacenter.properties.description
        datacenter_list << datacenter.properties.location
        datacenter_list << datacenter.properties.version.to_s
        datacenter_list << datacenter.properties.sec_auth_protection.to_s
      end

      expect(subject.ui).to receive(:list).with(datacenter_list, :uneven_columns_across, 6)

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: '/datacenters',
            operation: :'DataCenterApi.datacenters_get',
            return_type: 'Datacenters',
            result: datacenters,
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
