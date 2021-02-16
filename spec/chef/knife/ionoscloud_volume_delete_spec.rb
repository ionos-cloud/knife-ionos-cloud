require 'spec_helper'
require 'ionoscloud_volume_delete'

Chef::Knife::IonoscloudVolumeDelete.load_deps

describe Chef::Knife::IonoscloudVolumeDelete do
  subject { Chef::Knife::IonoscloudVolumeDelete.new }

  before :each do
    @datacenter = create_test_datacenter()

    allow(subject).to receive(:puts)
    allow(subject.ui).to receive(:warn)
    allow(subject).to receive(:confirm)
  end

  after :each do
    Ionoscloud::DataCenterApi.new.datacenters_delete_with_http_info(@datacenter.id)
  end

  describe '#run' do
    it 'should delete a volume' do
      @volume = create_test_volume(@datacenter)
      subject.name_args = [@volume.id]

      {
        ionoscloud_username: ENV['IONOS_USERNAME'],
        ionoscloud_password: ENV['IONOS_PASSWORD'],
        datacenter_id: @datacenter.id,
      }.each do |key, value|
        subject.config[key] = value
      end

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
        ionoscloud_username: ENV['IONOS_USERNAME'],
        ionoscloud_password: ENV['IONOS_PASSWORD'],
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
