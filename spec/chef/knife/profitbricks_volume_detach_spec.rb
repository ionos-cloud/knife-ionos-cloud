require 'spec_helper'
require 'profitbricks_volume_detach'

Chef::Knife::ProfitbricksVolumeDetach.load_deps

describe Chef::Knife::ProfitbricksVolumeDetach do
  subject { Chef::Knife::ProfitbricksVolumeDetach.new }

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

    @volume, _, volume_headers = Ionoscloud::VolumeApi.new.datacenters_volumes_post_with_http_info(
      @datacenter.id,
      {
        properties: {
          size: 4,
          type: 'HDD',
          availabilityZone: 'ZONE_3',
          imageAlias: 'ubuntu:latest',
          imagePassword: 'K3tTj8G14a3EgKyNeeiY',
          name: 'Test Volume'
        },
      },
    )

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
    Ionoscloud::ApiClient.new.wait_for { is_done? get_request_id volume_headers }

    _, _, headers = Ionoscloud::ServerApi.new.datacenters_servers_volumes_post_with_http_info(
      @datacenter.id, @server.id, { id: @volume.id },
    )
    Ionoscloud::ApiClient.new.wait_for { is_done? get_request_id headers }

    @volume = Ionoscloud::VolumeApi.new.datacenters_volumes_find_by_id(@datacenter.id, @volume.id)

    allow(subject).to receive(:puts)
    allow(subject.ui).to receive(:msg)
  end

  after :each do
    Ionoscloud::DataCenterApi.new.datacenters_delete_with_http_info(@datacenter.id)
  end

  describe '#run' do
    it 'should detach a volume' do
      {
        profitbricks_username: ENV['IONOS_USERNAME'],
        profitbricks_password: ENV['IONOS_PASSWORD'],
        datacenter_id: @datacenter.id,
        server_id: @server.id,
      }.each do |key, value|
        subject.config[key] = value
      end
      subject.config[:yes] = true
      subject.name_args = [@volume.id]

      expect(subject).to receive(:puts).with("ID: #{@volume.id}")
      expect(subject).to receive(:puts).with("Name: #{@volume.properties.name}")
      expect(subject).to receive(:puts).with("Size: #{@volume.properties.size}")
      expect(subject).to receive(:puts).with("Bus: #{@volume.properties.bus}")
      expect(subject).to receive(:puts).with("Device Number: #{@volume.properties.device_number}")

      expect(subject.ui).to receive(:msg).with("Detaching volume #{@volume.id} from server")

      subject.run
    end
  end
end
