require 'spec_helper'
require 'ionoscloud_lan_list'

Chef::Knife::IonoscloudLanList.load_deps

describe Chef::Knife::IonoscloudLanList do
  before :each do
    subject { Chef::Knife::IonoscloudLanList.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call LanApi.datacenters_lans_get' do
      lans = lans_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      lan_list = [
        subject.ui.color('ID', :bold),
        subject.ui.color('Name', :bold),
        subject.ui.color('Public', :bold),
        subject.ui.color('PCC', :bold),
        subject.ui.color('IP Failover Count', :bold),
      ]

      lans.items.each do |lan|
        lan_list << lan.id
        lan_list << lan.properties.name
        lan_list << lan.properties.public.to_s
        lan_list << lan.properties.pcc
        lan_list << (lan.properties.ip_failover.nil? ? 0 : lan.properties.ip_failover.length)
      end

      expect(subject.ui).to receive(:list).with(lan_list, :uneven_columns_across, 5)

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/lans",
            operation: :'LanApi.datacenters_lans_get',
            return_type: 'Lans',
            result: lans,
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
