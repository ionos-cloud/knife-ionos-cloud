require 'spec_helper'
require 'profitbricks_volume_create'

Chef::Knife::ProfitbricksVolumeCreate.load_deps

describe Chef::Knife::ProfitbricksVolumeCreate do
  subject { Chef::Knife::ProfitbricksVolumeCreate.new }

  before :each do
    @datacenter = create_test_datacenter()

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  after :each do
    Ionoscloud::DataCenterApi.new.datacenters_delete_with_http_info(@datacenter.id)
  end

  describe '#run' do
    it 'should create a volume' do
      image_alias = 'debian:latest'
      size = 2
      name = 'Chef Test'
      type = 'HDD'
      image_password = 'K3tTj8G14a3EgKyNeeiY'
      volume_availability_zone = 'AUTO'
      licence_type = 'LINUX'

      {
        profitbricks_username: ENV['IONOS_USERNAME'],
        profitbricks_password: ENV['IONOS_PASSWORD'],
        datacenter_id: @datacenter.id,
        imagealias: image_alias,
        size: size,
        name: name,
        type: type,
        imagepassword: image_password,
        volume_availability_zone: volume_availability_zone,
        licencetype: licence_type,
      }.each do |key, value|
        subject.config[key] = value
      end

      expect(subject).to receive(:puts).with(/^ID: (\b[0-9a-f]{8}\b-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-\b[0-9a-f]{12})\b$/)
      expect(subject).to receive(:puts).with("Name: #{name}")
      expect(subject).to receive(:puts).with("Size: #{'%.1f' % size}")
      expect(subject).to receive(:puts).with('Bus: ')
      expect(subject).to receive(:puts).with(/^Image: (\b[0-9a-f]{8}\b-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-\b[0-9a-f]{12})\b$/)
      expect(subject).to receive(:puts).with("Type: #{type}")
      expect(subject).to receive(:puts).with("Licence Type: #{licence_type}")
      expect(subject).to receive(:puts).with("Zone: #{volume_availability_zone}")

      subject.run

      volume = Ionoscloud::VolumeApi.new.datacenters_volumes_get(@datacenter.id, { depth: 1 }).items.first

      expect(volume.properties.name).to eq(name)
      expect(volume.properties.type).to eq(type)
      expect(volume.properties.size.to_s).to eq('%.1f' % size)
      expect(volume.properties.licence_type).to eq(licence_type)
      expect(volume.properties.availability_zone).to eq(volume_availability_zone)
      expect(volume.metadata.state).to eq('AVAILABLE')
      expect(volume.metadata.created_by).to eq(ENV['IONOS_USERNAME'])
      expect(volume.metadata.last_modified_by).to eq(ENV['IONOS_USERNAME'])
    end
  end
end
