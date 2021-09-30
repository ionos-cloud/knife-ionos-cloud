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

      check_ipblock_print(subject, ipblock)

      expected_body = ipblock.properties.to_hash
      expected_body.delete(:ips)

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'POST',
            path: '/ipblocks',
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
      check_required_options(subject)
    end
  end
end
