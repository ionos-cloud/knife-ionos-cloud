require 'spec_helper'
require 'ionoscloud_lan_create'

Chef::Knife::IonoscloudLanCreate.load_deps

describe Chef::Knife::IonoscloudLanCreate do
  subject { Chef::Knife::IonoscloudLanCreate.new }

  before :each do
    @datacenter = create_test_datacenter()

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  after :each do
    Ionoscloud::DataCenterApi.new.datacenters_delete_with_http_info(@datacenter.id)
  end

  describe '#run' do
    it 'should create a lan' do
      lan_name = 'Chef Test'
      lan_public = true
  
      {
        ionoscloud_username: ENV['IONOS_USERNAME'],
        ionoscloud_password: ENV['IONOS_PASSWORD'],
        name: lan_name,
        public: lan_public,
        datacenter_id: @datacenter.id,
      }.each do |key, value|
        subject.config[key] = value
      end

      expect(subject).to receive(:puts).with(/^ID: ([0-9]*)$/)
      expect(subject).to receive(:puts).with("Name: #{lan_name}")
      expect(subject).to receive(:puts).with("Public: #{lan_public}")
      subject.run

      lan = Ionoscloud::LanApi.new.datacenters_lans_get(@datacenter.id, { depth: 1 }).items.first

      expect(lan.properties.name).to eq(lan_name)
      expect(lan.properties.public).to eq(lan_public)
      expect(lan.metadata.state).to eq('AVAILABLE')
      expect(lan.metadata.created_by).to eq(ENV['IONOS_USERNAME'])
      expect(lan.metadata.last_modified_by).to eq(ENV['IONOS_USERNAME'])
    end
  end
end
