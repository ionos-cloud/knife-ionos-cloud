require 'spec_helper'
require 'profitbricks_ipblock_create'

Chef::Knife::ProfitbricksIpblockCreate.load_deps

describe Chef::Knife::ProfitbricksIpblockCreate do
  subject { Chef::Knife::ProfitbricksIpblockCreate.new }

  before :each do
    Ionoscloud.configure do |config|
      config.username = ENV['IONOS_USERNAME']
      config.password = ENV['IONOS_PASSWORD']
    end
    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  after :each do
    Ionoscloud::IPBlocksApi.new.ipblocks_delete(@ipblock_id) unless @ipblock_id.nil?
  end

  describe '#run' do
    it 'should reserve a IP block' do
      location = 'us/las'
      size = 1
      {
        profitbricks_username: ENV['IONOS_USERNAME'],
        profitbricks_password: ENV['IONOS_PASSWORD'],
        location: location,
        size: size,
      }.each do |key, value|
        subject.config[key] = value
      end

      expect(subject).to receive(:puts).with(/^ID: (\b[0-9a-f]{8}\b-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-\b[0-9a-f]{12})\b$/) do |argument|
        @ipblock_id = argument.split(' ').last
      end
      expect(subject).to receive(:puts).with("Location: #{location}")

      block = /\d{,2}|1\d{2}|2[0-4]\d|25[0-5]/
      expect(subject).to receive(:puts).with(/\A^IP Addresses: \["#{block}\.#{block}\.#{block}\.#{block}"\]\z/)
      
      subject.run

      if @ipblock_id
        ip_block = Ionoscloud::IPBlocksApi.new.ipblocks_find_by_id(@ipblock_id)

        expect(ip_block.properties.size).to eq(size)
        expect(ip_block.properties.location).to eq(location)
        expect(ip_block.properties.ips.length).to eq(size)

        expect(ip_block.metadata.state).to eq('AVAILABLE')
        expect(ip_block.metadata.created_by).to eq(ENV['IONOS_USERNAME'])
        expect(ip_block.metadata.last_modified_by).to eq(ENV['IONOS_USERNAME'])
      end
    end
  end
end
