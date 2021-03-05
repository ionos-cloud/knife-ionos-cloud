require 'spec_helper'
require 'ionoscloud_ipblock_create'

Chef::Knife::IonoscloudIpblockCreate.load_deps

describe Chef::Knife::IonoscloudIpblockCreate do
  before :each do
    subject { Chef::Knife::IonoscloudIpblockCreate.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call IPBlocksApi.ipblocks_post with the expected arguments and output based on what it receives' do
      ipblock = ipblock_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        ipblock_id: 'ipblock_id',
        name: ipblock.properties.name,
        size: ipblock.properties.size,
        location: ipblock.properties.location,
      }
 
      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{ipblock.id}")
      expect(subject).to receive(:puts).with("Name: #{ipblock.properties.name}")
      expect(subject).to receive(:puts).with("IP Addresses: #{ipblock.properties.ips.to_s}")
      expect(subject).to receive(:puts).with("Location: #{ipblock.properties.location}")

      expected_body = ipblock.properties.to_hash
      expected_body.delete(:ips)

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'POST',
            path: "/ipblocks",
            operation: :'IPBlocksApi.ipblocks_post',
            return_type: 'IpBlock',
            body: { properties: expected_body },
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
