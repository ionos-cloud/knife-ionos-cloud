require 'spec_helper'
require 'ionoscloud_ipblock_update'

Chef::Knife::IonoscloudIpblockUpdate.load_deps

describe Chef::Knife::IonoscloudIpblockUpdate do
  before :each do
    subject { Chef::Knife::IonoscloudIpblockUpdate.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call DataCenterApi.datacenters_patch' do
      ipblock = ipblock_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        ipblock_id: ipblock.id,
        name: ipblock.properties.name + '_edited',
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      ip_consumers = (ipblock.properties.ip_consumers.nil? ? [] : ipblock.properties.ip_consumers.map { |el| el.to_hash })
      expect(subject).to receive(:puts).with("ID: #{ipblock.id}")
      expect(subject).to receive(:puts).with("Name: #{subject_config[:name]}")
      expect(subject).to receive(:puts).with("IP Addresses: #{ipblock.properties.ips.to_s}")
      expect(subject).to receive(:puts).with("Location: #{ipblock.properties.location}")
      expect(subject).to receive(:puts).with("IP Consumers: #{ip_consumers}")

      ipblock.properties.name = subject_config[:name]

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'PATCH',
            path: "/ipblocks/#{ipblock.id}",
            operation: :'IPBlocksApi.ipblocks_patch',
            return_type: 'IpBlock',
            body: { name: subject_config[:name] },
            result: ipblock,
          },
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
