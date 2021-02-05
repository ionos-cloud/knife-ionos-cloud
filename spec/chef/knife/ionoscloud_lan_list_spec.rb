require 'spec_helper'
require 'ionoscloud_lan_list'

Chef::Knife::IonoscloudLanList.load_deps

describe Chef::Knife::IonoscloudLanList do
  subject { Chef::Knife::IonoscloudLanList.new }

  before :each do
    @datacenter = create_test_datacenter()
    @lan = create_test_lan(@datacenter)
  end

  after :each do
    Ionoscloud::DataCenterApi.new.datacenters_delete_with_http_info(@datacenter.id)
  end

  describe '#run' do
    it 'should output the column headers and the lan' do
      {
        ionoscloud_username: ENV['IONOS_USERNAME'],
        ionoscloud_password: ENV['IONOS_PASSWORD'],
        datacenter_id: @datacenter.id,
      }.each do |key, value|
        subject.config[key] = value
      end
      allow(subject).to receive(:puts)

      expect(subject).to receive(:puts).with(
        /^ID\s+Name\s+Public\s*$\n#{@lan.id}\s+#{@lan.properties.name}\s+#{@lan.properties.public}\s*$/,
      )
      subject.run
    end
  end
end
