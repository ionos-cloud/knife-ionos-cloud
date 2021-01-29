require 'spec_helper'
require 'profitbricks_datacenter_create'

Chef::Knife::ProfitbricksDatacenterCreate.load_deps

describe Chef::Knife::ProfitbricksDatacenterCreate do
  subject { Chef::Knife::ProfitbricksDatacenterCreate.new }

  before :each do
    Ionoscloud.configure do |config|
      config.username = ENV['IONOS_USERNAME']
      config.password = ENV['IONOS_PASSWORD']
    end

    @datacenter_name = 'Chef test'
    @description = 'Chef test datacenter'
    @location = 'us/las'

    {
      profitbricks_username: ENV['IONOS_USERNAME'],
      profitbricks_password: ENV['IONOS_PASSWORD'],
      name: @datacenter_name,
      description: @description,
      location: @location
    }.each do |key, value|
      subject.config[key] = value
    end
    allow(subject).to receive(:puts)
  end

  after :each do
    dcid = subject.instance_variable_get :@dcid
    @datacenter = Ionoscloud::DataCenterApi.new.datacenters_delete(dcid)
  end

  describe '#run' do
    it 'should create a data center' do
      expect(subject).to receive(:puts).with(/^ID: (\b[0-9a-f]{8}\b-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-\b[0-9a-f]{12})\b$/)
      expect(subject).to receive(:puts).with("Name: #{@datacenter_name}")
      expect(subject).to receive(:puts).with("Description: #{@description}")
      expect(subject).to receive(:puts).with("Location: #{@location}")

      subject.run

      created_datacenter = Ionoscloud::DataCenterApi.new.datacenters_find_by_id(subject.instance_variable_get :@dcid)
      expect(created_datacenter.properties.name).to eq(@datacenter_name)
      expect(created_datacenter.properties.description).to eq(@description)
      expect(created_datacenter.properties.location).to eq(@location)
    end
  end
end
