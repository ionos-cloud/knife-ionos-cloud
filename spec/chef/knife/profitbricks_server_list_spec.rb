require 'spec_helper'
require 'profitbricks_server_list'

Chef::Knife::ProfitbricksServerList.load_deps

describe Chef::Knife::ProfitbricksServerList do
  subject { Chef::Knife::ProfitbricksServerList.new }

  before :each do
    @datacenter = create_test_datacenter()
    @server = create_test_server(@datacenter)
  
    allow(subject).to receive(:puts)
  end

  after :each do
    Ionoscloud::DataCenterApi.new.datacenters_delete_with_http_info(@datacenter.id)
  end

  describe '#run' do
    it 'should output the column headers' do
      {
        profitbricks_username: ENV['IONOS_USERNAME'],
        profitbricks_password: ENV['IONOS_PASSWORD'],
        datacenter_id: @datacenter.id,
      }.each do |key, value|
        subject.config[key] = value
      end

      expect(subject).to receive(:puts).with(
        %r{
          (^ID\s+Name\s+Cores\s+RAM\s+Availability\sZone\s+VM\sState\s+Boot\sVolume\s+Boot\sCDROM\s*$\n
            #{@server.id}\s+#{@server.properties.name.gsub(' ', '\s')}\s+#{@server.properties.cores}\s+
            #{@server.properties.ram}\s+#{@server.properties.availability_zone}\s+#{@server.properties.vm_state}
            \s+#{(@server.properties.boot_volume == nil ? '' : @server.properties.boot_volume.id)}\s+
            #{(@server.properties.boot_cdrom == nil ? '' : @server.properties.boot_cdrom.id)}\s*$)
        }x
      )
      subject.run
    end
  end
end
