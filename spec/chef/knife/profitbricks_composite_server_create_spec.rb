require 'chef/knife/profitbricks_base'
require 'spec_helper'
require 'profitbricks_composite_server_create'

Chef::Knife::ProfitbricksCompositeServerCreate.load_deps

describe Chef::Knife::ProfitbricksCompositeServerCreate do
  subject { Chef::Knife::ProfitbricksCompositeServerCreate.new }

  Ionoscloud.configure do |config|
    config.username = ENV['IONOS_USERNAME']
    config.password = ENV['IONOS_PASSWORD']
  end

  def get_request_id headers
    headers['Location'].scan(%r{/requests/(\b[0-9a-f]{8}\b-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-\b[0-9a-f]{12}\b)}).last.first
  end

  def is_done? request_id
    response = Ionoscloud::RequestApi.new.requests_status_get(request_id)
    if response.metadata.status == 'FAILED'
      ui.error "Request #{request_id} failed\n" + response.metadata.message
      exit(1)
    end
    response.metadata.status == 'DONE'
  end

  datacenter_api = Ionoscloud::DataCenterApi.new

  before :each do
    datacenter, _, headers  = datacenter_api.datacenters_post_with_http_info({
      properties: {
        name: 'knife test',
        description: 'knife test datacenter',
        location: 'de/fra',
      },
    })
    Ionoscloud::ApiClient.new.wait_for { is_done? get_request_id headers }
    @dcid = datacenter.id
    allow(subject).to receive(:puts)

    {
      profitbricks_username: ENV['IONOS_USERNAME'],
      profitbricks_password: ENV['IONOS_PASSWORD'],
      name: 'knife test',
      cores: '1',
      ram: '1024',
      size: 4,
      dhcp: true,
      lan: 1,
      datacenter_id: @dcid,
      imagealias: 'ubuntu:latest',
      type: 'HDD',
      imagepassword: 'K3tTj8G14a3EgKyNeeiY',
      cpufamily: 'INTEL_SKYLAKE',
      availabilityzone: 'AUTO',
    }.each do |key, value|
      subject.config[key] = value
    end
  end

  after :each do
    # datacenter_api.datacenters_delete(@dcid)
  end

  describe '#run' do
    it 'should output the server name, cores, cpu family, ram and availability zone' do
      expect(subject).to receive(:puts).with('Name: knife test')
      expect(subject).to receive(:puts).with('Cores: 1')
      expect(subject).to receive(:puts).with('CPU Family: INTEL_SKYLAKE')
      expect(subject).to receive(:puts).with('Ram: 1024')
      expect(subject).to receive(:puts).with('Availability Zone: AUTO')
      subject.run
    end

    it 'should create the composite server' do
      servers = Ionoscloud::ServerApi.new.datacenters_servers_get(@dcid, {depth: 1}).items

      puts @dcid

      servers.each do |server|
        puts server.id
        puts server.properties.name
        puts server.properties.cores.to_s
        puts server.properties.ram.to_s
        puts server.properties.availability_zone
        puts server.properties.vm_state
        puts (server.properties.boot_volume == nil ? '' : server.properties.boot_volume.id)
        puts (server.properties.boot_cdrom == nil ? '' : server.properties.boot_cdrom.id)
      end
    end
  end
end
