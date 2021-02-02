require 'spec_helper'
require 'profitbricks_server_list'

Chef::Knife::ProfitbricksServerList.load_deps

describe Chef::Knife::ProfitbricksServerList do
  subject { Chef::Knife::ProfitbricksServerList.new }

  before :each do
    Ionoscloud.configure do |config|
      config.username = ENV['IONOS_USERNAME']
      config.password = ENV['IONOS_PASSWORD']
    end

    @datacenter, _, headers  = Ionoscloud::DataCenterApi.new.datacenters_post_with_http_info({
      properties: {
        name: 'Chef test Datacenter',
        description: 'Chef test datacenter',
        location: 'de/fra',
      },
    })
    Ionoscloud::ApiClient.new.wait_for { is_done? get_request_id headers }

    @server, _, headers  = Ionoscloud::ServerApi.new.datacenters_servers_post_with_http_info(
      @datacenter.id,
      {
        properties: {
          name: 'Chef test Server',
          ram: 1024,
          cores: 1,
          availabilityZone: 'ZONE_1',
          cpuFamily: 'INTEL_SKYLAKE',
        },
      },
    )
    Ionoscloud::ApiClient.new.wait_for { is_done? get_request_id headers }

    @server = Ionoscloud::ServerApi.new.datacenters_servers_find_by_id(@datacenter.id, @server.id)
  
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
        /^ID\s+Name\s+Cores\s+RAM\s+Availability Zone\s+VM State\s+Boot Volume\s+Boot CDROM\s*$\n#{@server.id}\s+#{@server.properties.name}\s+#{@server.properties.cores}\s+#{@server.properties.ram}\s+#{@server.properties.availability_zone}\s+#{@server.properties.vm_state}\s+#{(@server.properties.boot_volume == nil ? '' : @server.properties.boot_volume.id)}\s+#{(@server.properties.boot_cdrom == nil ? '' : @server.properties.boot_cdrom.id)}\s*$/,
      )
      subject.run
    end
  end
end
