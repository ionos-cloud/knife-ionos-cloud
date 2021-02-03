require 'spec_helper'
require 'profitbricks_volume_list'

Chef::Knife::ProfitbricksVolumeList.load_deps

describe Chef::Knife::ProfitbricksVolumeList do
  subject { Chef::Knife::ProfitbricksVolumeList.new }

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
  end

  after :each do
    Ionoscloud::DataCenterApi.new.datacenters_delete_with_http_info(@datacenter.id)
  end

  describe '#run' do
    it 'should list volumes' do
      {
        profitbricks_username: ENV['IONOS_USERNAME'],
        profitbricks_password: ENV['IONOS_PASSWORD'],
        datacenter_id: @datacenter.id,
      }.each do |key, value|
        subject.config[key] = value
      end

      expect(subject).to receive(:puts).with(
        /^ID\s+Name\s+Size\s+Bus\s+Image\s+Type\s+Zone\s+Device Number\s*$\n#{@volume.id}\s+#{@volume.properties.name}\s+#{@volume.properties.size}\s+#{@volume.properties.bus}\s+#{@volume.properties.image}\s+#{@volume.properties.type}\s+#{@volume.properties.availability_zone}\s+#{@volume.properties.device_number.to_s}\s*$/,
      )
      subject.run
    end
    it 'should print only headers if there are no volumes' do
      {
        profitbricks_username: ENV['IONOS_USERNAME'],
        profitbricks_password: ENV['IONOS_PASSWORD'],
        datacenter_id: @datacenter.id,
        server_id: @server.id,
      }.each do |key, value|
        subject.config[key] = value
      end

      expect(subject).to receive(:puts).with(
        /^ID\s+Name\s+Size\s+Bus\s+Image\s+Type\s+Zone\s+Device Number\s*\n$/,
      )
      subject.run
    end
  end
end
