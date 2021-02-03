require 'spec_helper'
require 'profitbricks_ipblock_delete'

Chef::Knife::ProfitbricksIpblockDelete.load_deps

describe Chef::Knife::ProfitbricksIpblockDelete do
  subject { Chef::Knife::ProfitbricksIpblockDelete.new }

  before :each do

    Ionoscloud.configure do |config|
      config.username = ENV['IONOS_USERNAME']
      config.password = ENV['IONOS_PASSWORD']
    end

    @ip_block, _, headers = Ionoscloud::IPBlocksApi.new.ipblocks_post_with_http_info(
      {
        properties: {
          location: 'de/fra',
          size: 1,
        },
      },
    )

    Ionoscloud::ApiClient.new.wait_for { is_done? get_request_id headers }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:confirm)
    allow(subject.ui).to receive(:warn)
  end

  after :each do
    begin
      Ionoscloud::IPBlocksApi.new.ipblocks_delete(@ip_block.id)
    rescue Exception
    end
  end

  describe '#run' do
    it 'should delete a data center' do
      {
        profitbricks_username: ENV['IONOS_USERNAME'],
        profitbricks_password: ENV['IONOS_PASSWORD'],
      }.each do |key, value|
        subject.config[key] = value
      end
      subject.config[:yes] = true
      subject.name_args = [@ip_block.id]

      expect(subject).to receive(:puts).with("ID: #{@ip_block.id}")
      expect(subject).to receive(:puts).with("Location: #{@ip_block.properties.location}")
      expect(subject).to receive(:puts).with("IP Addresses: #{@ip_block.properties.ips.to_s}")

      subject.run
    end
  end
end
