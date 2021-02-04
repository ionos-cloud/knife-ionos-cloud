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
      subject.name_args = [@volume.id]

      expect(subject.ui).to receive(:warn).with(
        /Deleted Volume #{@volume.id}. Request ID: (\b[0-9a-f]{8}\b-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-\b[0-9a-f]{12})\b/,
      ) do |arg|
        @request_id = arg.split('Request ID: ').last
      end

      expect(subject).to receive(:puts).with("ID: #{@volume.id}")
      expect(subject).to receive(:puts).with("Name: #{@volume.properties.name}")
      expect(subject).to receive(:puts).with("Size: #{@volume.properties.size}")
      expect(subject).to receive(:puts).with("Image: #{@volume.properties.image}")

      subject.run

      raise Exception.new 'No Request ID found.' unless @request_id

      request = Ionoscloud::RequestApi.new.requests_status_get(@request_id)

      expect(request.metadata.status).to eq('QUEUED').or(eq('DONE'))
      expect(request.metadata.message).to eq('Request has been queued').or(eq('Request has been successfully executed'))
      expect(request.metadata.targets.length).to eq(1)
      expect(request.metadata.targets.first.target.type).to eq('volume')
      expect(request.metadata.targets.first.target.id).to eq(@volume.id)

      Ionoscloud::ApiClient.new.wait_for { is_done? @request_id }
      
      expect {
        Ionoscloud::VolumeApi.new.datacenters_volumes_find_by_id(
          @datacenter.id,
          @volume.id,
        )
      }.to raise_error(Ionoscloud::ApiError) do |error|
        expect(error.code).to eq(404)
      end
    end

    it 'should print a message when wrong ID' do
      {
        profitbricks_username: ENV['IONOS_USERNAME'],
        profitbricks_password: ENV['IONOS_PASSWORD'],
        datacenter_id: @datacenter.id,
      }.each do |key, value|
        subject.config[key] = value
      end
      wrong_volume_ids = [123,]  
      subject.name_args = wrong_volume_ids

      expect(subject.ui).not_to receive(:warn)
      wrong_volume_ids.each {
        |wrong_volume_id|
        expect(subject.ui).to receive(:error).with("Volume ID #{wrong_volume_id} not found. Skipping.")
      }
      subject.run
    end
  end
end
