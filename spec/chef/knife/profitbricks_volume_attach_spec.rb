require 'spec_helper'
require 'profitbricks_volume_attach'

Chef::Knife::ProfitbricksVolumeAttach.load_deps

describe Chef::Knife::ProfitbricksVolumeAttach do
  subject { Chef::Knife::ProfitbricksVolumeAttach.new }

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

    @volume = Ionoscloud::VolumeApi.new.datacenters_volumes_find_by_id(@datacenter.id, @volume.id)

    allow(subject).to receive(:puts)
    allow(subject.ui).to receive(:msg)
  end

  after :each do
    Ionoscloud::DataCenterApi.new.datacenters_delete_with_http_info(@datacenter.id)
  end

  describe '#run' do
    it 'should attach a volume' do
      {
        profitbricks_username: ENV['IONOS_USERNAME'],
        profitbricks_password: ENV['IONOS_PASSWORD'],
        datacenter_id: @datacenter.id,
        server_id: @server.id,
      }.each do |key, value|
        subject.config[key] = value
      end
      subject.name_args = [@volume.id]

      expect(subject.ui).to receive(:msg).with(
        /Volume #{@volume.id} attached to server. Request ID: (\b[0-9a-f]{8}\b-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-\b[0-9a-f]{12})\b/,
      ) do |arg|
        @request_id = arg.split('Request ID: ').last
      end

      subject.run

      raise Exception.new 'No Request ID found.' unless @request_id

      request = Ionoscloud::RequestApi.new.requests_status_get(@request_id)

      expect(request.metadata.status).to eq('QUEUED').or(eq('DONE'))
      expect(request.metadata.message).to eq('Request has been queued').or(eq('Request has been successfully executed'))
      expect(request.metadata.targets.length).to eq(1)
      expect(request.metadata.targets.first.target.type).to eq('volume')
      expect(request.metadata.targets.first.target.id).to eq(@volume.id)

      Ionoscloud::ApiClient.new.wait_for { is_done? @request_id }
      
      volume = Ionoscloud::ServerApi.new.datacenters_servers_volumes_find_by_id(
        @datacenter.id, @server.id, @volume.id,
      )

      expect(volume.properties.bus).to eq('VIRTIO')
    end
  end
end
