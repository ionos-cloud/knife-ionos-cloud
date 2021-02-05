require 'spec_helper'
require 'profitbricks_volume_list'

Chef::Knife::ProfitbricksVolumeList.load_deps

describe Chef::Knife::ProfitbricksVolumeList do
  subject { Chef::Knife::ProfitbricksVolumeList.new }

  before :each do
    @datacenter = create_test_datacenter()
    @volume = create_test_volume(@datacenter)

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
        %r{
          (^ID\s+Name\s+Size\s+Bus\s+Image\s+Type\s+Zone\s+Device\sNumber\s*$\n
            #{@volume.id}\s+#{@volume.properties.name.gsub(' ', '\s')}\s+#{@volume.properties.size}\s+
            #{@volume.properties.bus}\s+#{@volume.properties.image}\s+#{@volume.properties.type}\s+
            #{@volume.properties.availability_zone}\s+#{@volume.properties.device_number.to_s}\s*$)
        }x,
      )
      subject.run
    end
    it 'should print only headers if there are no volumes' do
      @server = create_test_server(@datacenter)

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
