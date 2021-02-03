require 'spec_helper'
require 'profitbricks_volume_delete'

Chef::Knife::ProfitbricksVolumeDelete.load_deps

describe Chef::Knife::ProfitbricksVolumeDelete do
  subject { Chef::Knife::ProfitbricksVolumeDelete.new }

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

    @volume, _, headers = Ionoscloud::VolumeApi.new.datacenters_volumes_post_with_http_info(
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
    Ionoscloud::ApiClient.new.wait_for { is_done? get_request_id headers }

    allow(subject).to receive(:puts)
    allow(subject.ui).to receive(:warn)
    allow(subject).to receive(:confirm)
  end

  after :each do
    Ionoscloud::DataCenterApi.new.datacenters_delete_with_http_info(@datacenter.id)
  end

  describe '#run' do
    it 'should delete a volume' do
      {
        profitbricks_username: ENV['IONOS_USERNAME'],
        profitbricks_password: ENV['IONOS_PASSWORD'],
        datacenter_id: @datacenter.id,
      }.each do |key, value|
        subject.config[key] = value
      end
      subject.config[:yes] = true
      subject.name_args = [@volume.id]

      expect(subject).to receive(:puts).with("ID: #{@volume.id}")
      expect(subject).to receive(:puts).with("Name: #{@volume.properties.name}")
      expect(subject).to receive(:puts).with("Size: #{@volume.properties.size}")
      expect(subject).to receive(:puts).with("Image: #{@volume.properties.image}")

      subject.run
    end
  end
end
