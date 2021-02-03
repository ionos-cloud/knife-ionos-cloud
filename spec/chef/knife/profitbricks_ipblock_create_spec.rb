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
    Ionoscloud::IPBlocksApi.new.ipblocks_delete(subject.instance_variable_get :@ipid)
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

      expect(subject).to receive(:puts).with('done')
      subject.run

    ip_block = Ionoscloud::IPBlocksApi.new.ipblocks_find_by_id(subject.instance_variable_get :@ipid)

    expect(ip_block.properties.size).to eq(size)
    expect(ip_block.properties.location).to eq(location)
    expect(ip_block.properties.ips.length).to eq(size)

    expect(ip_block.metadata.state).to eq('AVAILABLE')
    expect(ip_block.metadata.created_by).to eq(ENV['IONOS_USERNAME'])
    expect(ip_block.metadata.last_modified_by).to eq(ENV['IONOS_USERNAME'])
    end
  end
end
