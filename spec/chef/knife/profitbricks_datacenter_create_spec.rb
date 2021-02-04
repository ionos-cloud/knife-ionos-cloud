require 'spec_helper'
require 'profitbricks_datacenter_create'

Chef::Knife::ProfitbricksDatacenterCreate.load_deps

describe Chef::Knife::ProfitbricksDatacenterCreate do
  subject { Chef::Knife::ProfitbricksDatacenterCreate.new }

  after :each do
    Ionoscloud::DataCenterApi.new.datacenters_delete(@datacenter_id) unless @datacenter_id.nil?
  end

  describe '#run' do
    it 'should create a data center' do
      datacenter_name = 'Chef test'
      description = 'Chef test datacenter'
      location = 'us/las'

      {
        profitbricks_username: ENV['IONOS_USERNAME'],
        profitbricks_password: ENV['IONOS_PASSWORD'],
        name: datacenter_name,
        description: description,
        location: location
      }.each do |key, value|
        subject.config[key] = value
      end

      allow(subject).to receive(:puts)
      allow(subject).to receive(:print)

      expect(subject).to receive(:puts).with(/^ID: (\b[0-9a-f]{8}\b-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-\b[0-9a-f]{12})\b$/) do |argument|
        @datacenter_id = argument.split(' ').last
      end
      expect(subject).to receive(:puts).with("Name: #{datacenter_name}")
      expect(subject).to receive(:puts).with("Description: #{description}")
      expect(subject).to receive(:puts).with("Location: #{location}")

      subject.run

      if @datacenter_id
        created_datacenter = Ionoscloud::DataCenterApi.new.datacenters_find_by_id(@datacenter_id)
        
        expect(created_datacenter.properties.name).to eq(datacenter_name)
        expect(created_datacenter.properties.description).to eq(description)
        expect(created_datacenter.properties.location).to eq(location)
        expect(created_datacenter.metadata.state).to eq('AVAILABLE')
        expect(created_datacenter.metadata.created_by).to eq(ENV['IONOS_USERNAME'])
        expect(created_datacenter.metadata.last_modified_by).to eq(ENV['IONOS_USERNAME'])
      end
    end
  end
end
