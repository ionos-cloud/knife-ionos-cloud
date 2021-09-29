require 'spec_helper'
require 'ionoscloud_ipblock_get'

Chef::Knife::IonoscloudIpblockGet.load_deps

describe Chef::Knife::IonoscloudIpblockGet do
  before :each do
    subject { Chef::Knife::IonoscloudIpblockGet.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call IPBlocksApi.ipblocks_find_by_id' do
      ipblock = ipblock_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        ipblock_id: ipblock.id,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      ip_consumers = (ipblock.properties.ip_consumers.nil? ? [] : ipblock.properties.ip_consumers.map { |el| el.to_hash })
      expect(subject).to receive(:puts).with("ID: #{ipblock.id}")
      expect(subject).to receive(:puts).with("Name: #{ipblock.properties.name}")
      expect(subject).to receive(:puts).with("IP Addresses: #{ipblock.properties.ips.to_s}")
      expect(subject).to receive(:puts).with("Location: #{ipblock.properties.location}")
      expect(subject).to receive(:puts).with("IP Consumers: #{ip_consumers}")

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/ipblocks/#{ipblock.id}",
            operation: :'IPBlocksApi.ipblocks_find_by_id',
            return_type: 'IpBlock',
            result: ipblock,
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
