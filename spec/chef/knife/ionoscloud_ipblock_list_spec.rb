require 'spec_helper'
require 'ionoscloud_ipblock_list'

Chef::Knife::IonoscloudIpblockList.load_deps

describe Chef::Knife::IonoscloudIpblockList do
  subject { Chef::Knife::IonoscloudIpblockList.new }

  before :each do
    @ipblock = create_test_ipblock()

    allow(subject).to receive(:puts)
  end

  after :each do
    Ionoscloud::IPBlocksApi.new.ipblocks_delete(@ipblock.id)
  end

  describe '#run' do
    it 'should output the column headers and the ipblock' do
      {
        ionoscloud_username: ENV['IONOS_USERNAME'],
        ionoscloud_password: ENV['IONOS_PASSWORD'],
      }.each do |key, value|
        subject.config[key] = value
      end

      expect(subject).to receive(:puts).with(
        %r{
          (^ID\s+Name\s+Location\s+IP\sAddresses\s*$\n.*#{@ipblock.id}\s+
            #{@ipblock.properties.name.to_s.gsub(' ', '\s')}\s+#{@ipblock.properties.location}
            \s+#{@ipblock.properties.ips.join(", ").to_s.gsub(' ', '\s')}\s*$)
        }x
      )
      subject.run
    end
  end
end
