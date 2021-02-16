require 'spec_helper'
require 'ionoscloud_server_create'

Chef::Knife::IonoscloudServerCreate.load_deps

describe Chef::Knife::IonoscloudServerCreate do
  subject { Chef::Knife::IonoscloudServerCreate.new }

  before :each do
    @datacenter = create_test_datacenter()

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  after :each do
    Ionoscloud::DataCenterApi.new.datacenters_delete_with_http_info(@datacenter.id)
  end

  describe '#run' do
    it 'should create a server' do
      server_cores = 2
      server_ram = 2048
      server_name = 'Chef Test'
      cpu_family = 'INTEL_SKYLAKE'
      availability_zone = 'AUTO'

      {
        ionoscloud_username: ENV['IONOS_USERNAME'],
        ionoscloud_password: ENV['IONOS_PASSWORD'],
        datacenter_id: @datacenter.id,
        cores: server_cores,
        ram: server_ram,
        name: server_name,
        cpuFamily: cpu_family,
        availabilityZone: availability_zone,
      }.each do |key, value|
        subject.config[key] = value
      end

      expect(subject).to receive(:puts).with(/^ID: (\b[0-9a-f]{8}\b-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-\b[0-9a-f]{12})\b$/)
      expect(subject).to receive(:puts).with("Name: #{server_name}")
      expect(subject).to receive(:puts).with("Cores: #{server_cores}")
      expect(subject).to receive(:puts).with("CPU Family: #{cpu_family}")
      expect(subject).to receive(:puts).with("Ram: #{server_ram}")
      expect(subject).to receive(:puts).with("Availability Zone: #{availability_zone}")
      expect(subject).to receive(:puts).with("Boot Volume: ")
      expect(subject).to receive(:puts).with("Boot CDROM: ")

      subject.run

      server = Ionoscloud::ServerApi.new.datacenters_servers_get(@datacenter.id, { depth: 3 }).items.first

      expect(server.properties.name).to eq(server_name)
      expect(server.properties.cores).to eq(server_cores)
      expect(server.properties.ram).to eq(server_ram)
      expect(server.properties.vm_state).to eq('RUNNING')
      expect(server.properties.boot_volume).to be_nil
      expect(server.properties.boot_cdrom).to be_nil
      expect(server.metadata.state).to eq('AVAILABLE')
      expect(server.metadata.created_by).to eq(ENV['IONOS_USERNAME'])
      expect(server.metadata.last_modified_by).to eq(ENV['IONOS_USERNAME'])

      expect(server.entities.cdroms.items).to be_empty
      expect(server.entities.nics.items).to be_empty
    end
  end
end
