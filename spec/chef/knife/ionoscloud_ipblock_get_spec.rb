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

      check_ipblock_print(subject, ipblock)

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
      check_required_options(subject)
    end
  end
end
