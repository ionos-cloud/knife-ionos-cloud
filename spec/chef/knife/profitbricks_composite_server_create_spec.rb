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

    @server_name = 'knife test'
    @availability_zone = 'AUTO'
    @ram = '1024'
    @cores = '1'
    @cpufamily = 'INTEL_SKYLAKE'
    @volume_type = 'HDD'
    @volume_size = 4
    @dhpc = true
    @lan_id = 1

    {
      profitbricks_username: ENV['IONOS_USERNAME'],
      profitbricks_password: ENV['IONOS_PASSWORD'],
      name: @server_name,
      cores: @cores,
      ram: @ram,
      size: @volume_size,
      dhcp: @dhpc,
      lan: @lan_id,
      datacenter_id: @dcid,
      imagealias: 'ubuntu:latest',
      type: @volume_type,
      imagepassword: 'K3tTj8G14a3EgKyNeeiY',
      cpufamily: @cpufamily,
      availabilityzone: @availability_zone,
    }.each do |key, value|
      subject.config[key] = value
    end
  end

  after :each do
    datacenter_api.datacenters_delete(@dcid)
  end

  describe '#run' do
    it 'should output the server name, cores, cpu family, ram and availability zone and create the composite server'  do

      expect(subject).to receive(:puts).with("Name: #{@server_name}")
      expect(subject).to receive(:puts).with("Cores: #{@cores}")
      expect(subject).to receive(:puts).with("CPU Family: #{@cpufamily}")
      expect(subject).to receive(:puts).with("Ram: #{@ram}")
      expect(subject).to receive(:puts).with("Availability Zone: #{@availability_zone}")

      subject.run

      Ionoscloud::ServerApi.new.datacenters_servers_get(@dcid, {depth: 3}).items.each do |server|
        expect(server.properties.name).to eq(@server_name)
        expect(server.properties.cores.to_s).to eq(@cores)
        expect(server.properties.ram.to_s).to eq(@ram)
        expect(server.properties.availability_zone).to eq(@availability_zone)
        expect(server.properties.vm_state).to eq('RUNNING')
        expect(server.properties.boot_volume.id).to be_instance_of(String)
        expect(server.properties.boot_cdrom).to be_nil
        expect(server.metadata.state).to eq('AVAILABLE')
        expect(server.metadata.created_by).to eq(ENV['IONOS_USERNAME'])
        expect(server.metadata.last_modified_by).to eq(ENV['IONOS_USERNAME'])

        expect(server.entities.cdroms.items).to be_empty

        expect(server.entities.volumes.items).not_to be_empty
        expect(server.entities.volumes.items.first.properties.type).to eq(@volume_type)
        expect(server.entities.volumes.items.first.properties.size.to_s).to eq('%.1f' % @volume_size)
        expect(server.entities.volumes.items.first.metadata.state).to eq('AVAILABLE')
        expect(server.entities.volumes.items.first.metadata.created_by).to eq(ENV['IONOS_USERNAME'])
        expect(server.entities.volumes.items.first.metadata.last_modified_by).to eq(ENV['IONOS_USERNAME'])

        expect(server.entities.nics.items).not_to be_empty
        expect(server.entities.nics.items.first.properties.dhcp).to eq(@dhpc)
        expect(server.entities.nics.items.first.properties.lan).to eq(@lan_id)
        expect(server.entities.volumes.items.first.metadata.state).to eq('AVAILABLE')
        expect(server.entities.volumes.items.first.metadata.created_by).to eq(ENV['IONOS_USERNAME'])
        expect(server.entities.volumes.items.first.metadata.last_modified_by).to eq(ENV['IONOS_USERNAME'])
      end
    end
  end
end
