require 'spec_helper'
require 'ionoscloud_composite_server_create'

Chef::Knife::IonoscloudCompositeServerCreate.load_deps

describe Chef::Knife::IonoscloudCompositeServerCreate do
  subject { Chef::Knife::IonoscloudCompositeServerCreate.new }

  before :each do
    @datacenter = create_test_datacenter()
  end

  after :each do
    Ionoscloud::DataCenterApi.new.datacenters_delete(@datacenter.id)
  end

  describe '#run' do
    it 'should output the server name, cores, cpu family, ram and availability zone and create the composite server'  do
      server_name = 'knife test'
      availability_zone = 'AUTO'
      server_ram = '1024'
      server_cores = '1'
      cpu_family = 'INTEL_SKYLAKE'
      volume_type = 'HDD'
      volume_size = 2
      dhpc = true
      lan_id = 1

      {
        ionoscloud_username: ENV['IONOS_USERNAME'],
        ionoscloud_password: ENV['IONOS_PASSWORD'],
        name: server_name,
        cores: server_cores,
        ram: server_ram,
        size: volume_size,
        dhcp: dhpc,
        lan: lan_id,
        datacenter_id: @datacenter.id,
        imagealias: 'debian:latest',
        type: volume_type,
        imagepassword: 'K3tTj8G14a3EgKyNeeiY',
        cpufamily: cpu_family,
        availabilityzone: availability_zone,
      }.each do |key, value|
        subject.config[key] = value
      end

      allow(subject).to receive(:puts)
      allow(subject).to receive(:print)

      expect(subject).to receive(:puts).with(/^ID: (\b[0-9a-f]{8}\b-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-\b[0-9a-f]{12})\b$/)
      expect(subject).to receive(:puts).with("Name: #{server_name}")
      expect(subject).to receive(:puts).with("Cores: #{server_cores}")
      expect(subject).to receive(:puts).with("CPU Family: #{cpu_family}")
      expect(subject).to receive(:puts).with("Ram: #{server_ram}")
      expect(subject).to receive(:puts).with("Availability Zone: #{availability_zone}")

      subject.run

      server = Ionoscloud::ServerApi.new.datacenters_servers_get(@datacenter.id, { depth: 3 }).items.first

      expect(server.properties.name).to eq(server_name)
      expect(server.properties.cores.to_s).to eq(server_cores)
      expect(server.properties.ram.to_s).to eq(server_ram)
      expect(server.properties.availability_zone).to eq(availability_zone)
      expect(server.properties.vm_state).to eq('RUNNING')
      expect(server.properties.boot_volume.id).to be_instance_of(String)
      expect(server.properties.boot_cdrom).to be_nil
      expect(server.metadata.state).to eq('AVAILABLE')
      expect(server.metadata.created_by).to eq(ENV['IONOS_USERNAME'])
      expect(server.metadata.last_modified_by).to eq(ENV['IONOS_USERNAME'])

      expect(server.entities.cdroms.items).to be_empty

      expect(server.entities.volumes.items).not_to be_empty
      expect(server.entities.volumes.items.first.properties.type).to eq(volume_type)
      expect(server.entities.volumes.items.first.properties.size.to_s).to eq('%.1f' % volume_size)
      expect(server.entities.volumes.items.first.metadata.state).to eq('AVAILABLE')
      expect(server.entities.volumes.items.first.metadata.created_by).to eq(ENV['IONOS_USERNAME'])
      expect(server.entities.volumes.items.first.metadata.last_modified_by).to eq(ENV['IONOS_USERNAME'])

      expect(server.entities.nics.items).not_to be_empty
      expect(server.entities.nics.items.first.properties.dhcp).to eq(dhpc)
      expect(server.entities.nics.items.first.properties.lan).to eq(lan_id)
      expect(server.entities.volumes.items.first.metadata.state).to eq('AVAILABLE')
      expect(server.entities.volumes.items.first.metadata.created_by).to eq(ENV['IONOS_USERNAME'])
      expect(server.entities.volumes.items.first.metadata.last_modified_by).to eq(ENV['IONOS_USERNAME'])
    end
  end
end
