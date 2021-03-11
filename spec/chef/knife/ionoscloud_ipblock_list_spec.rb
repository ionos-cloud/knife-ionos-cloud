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
      ]

      ipblocks.items.each do |ipblock|
        ipblock_list << ipblock.id
        ipblock_list << ipblock.properties.name
        ipblock_list << ipblock.properties.location
        ipblock_list << ipblock.properties.ips.join(', ')
      end

      expect(subject.ui).to receive(:list).with(ipblock_list, :uneven_columns_across, 4)

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
