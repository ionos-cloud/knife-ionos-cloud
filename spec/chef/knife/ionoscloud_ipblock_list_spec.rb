require 'spec_helper'
require 'ionoscloud_ipblock_list'

Chef::Knife::IonoscloudIpblockList.load_deps

describe Chef::Knife::IonoscloudIpblockList do
  before :each do
    subject { Chef::Knife::IonoscloudIpblockList.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call IPBlocksApi.ipblocks_get' do
      ipblocks = ipblocks_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      ipblock_list = [
        subject.ui.color('ID', :bold),
        subject.ui.color('Name', :bold),
        subject.ui.color('Location', :bold),
        subject.ui.color('IP Addresses', :bold),
        subject.ui.color('IP Consumers count', :bold),
      ]

      ipblocks.items.each do |ipblock|
        ipblock_list << ipblock.id
        ipblock_list << ipblock.properties.name
        ipblock_list << ipblock.properties.location
        ipblock_list << ipblock.properties.ips.join(', ')
        ipblock_list << ipblock.properties.ip_consumers.nil? ? 0 : ipblock.properties.ip_consumers.length
      end

      expect(subject.ui).to receive(:list).with(ipblock_list, :uneven_columns_across, 5)

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: '/ipblocks',
            operation: :'IPBlocksApi.ipblocks_get',
            return_type: 'IpBlocks',
            result: ipblocks,
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
