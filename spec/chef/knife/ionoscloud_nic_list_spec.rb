require 'spec_helper'
require 'ionoscloud_nic_list'

Chef::Knife::IonoscloudNicList.load_deps

describe Chef::Knife::IonoscloudNicList do
  before :each do
    subject { Chef::Knife::IonoscloudNicList.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call NicApi.datacenters_servers_nics_get' do
      nics = nics_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        server_id: 'server_id',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      nic_list = [
        subject.ui.color('ID', :bold),
        subject.ui.color('Name', :bold),
        subject.ui.color('IPs', :bold),
        subject.ui.color('DHCP', :bold),
        subject.ui.color('NAT', :bold),
        subject.ui.color('LAN', :bold),
        nics.items.first.id,
        nics.items.first.properties.name,
        nics.items.first.properties.ips.to_s,
        nics.items.first.properties.dhcp.to_s,
        nics.items.first.properties.nat.to_s,
        nics.items.first.properties.lan.to_s,
        nics.items[1].id,
        nics.items[1].properties.name,
        nics.items[1].properties.ips.to_s,
        nics.items[1].properties.dhcp.to_s,
        nics.items[1].properties.nat.to_s,
        nics.items[1].properties.lan.to_s,
      ]

      expect(subject.ui).to receive(:list).with(nic_list, :uneven_columns_across, 6)

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers/#{subject_config[:server_id]}/nics",
            operation: :'NicApi.datacenters_servers_nics_get',
            return_type: 'Nics',
            result: nics,
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
