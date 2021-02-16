require 'spec_helper'
require 'ionoscloud_datacenter_create'

Chef::Knife::IonoscloudDatacenterCreate.load_deps

describe Chef::Knife::IonoscloudDatacenterCreate do
  subject { Chef::Knife::IonoscloudDatacenterCreate.new }

  after :each do
    Ionoscloud::DataCenterApi.new.datacenters_delete(@datacenter_id) unless @datacenter_id.nil?
  end

  describe '#run' do
    it 'should fail if location is not provided' do
      datacenter_name = 'Chef test'
      description = 'Chef test datacenter'
      {
        ionoscloud_username: ENV['IONOS_USERNAME'],
        ionoscloud_password: ENV['IONOS_PASSWORD'],
        name: datacenter_name,
        description: description,
      }.each do |key, value|
        subject.config[key] = value
      end

      allow(subject).to receive(:puts)
      allow(subject).to receive(:print)
      
      expect(subject).to receive(:puts).with('Missing required parameters [:location]')

      expect { subject.run }.to raise_error(SystemExit) do |error|
        expect(error.status).to eq(1)
      end
    end

    it 'should create a data center' do
      datacenter_name = 'Chef test'
      description = 'Chef test datacenter'
      location = 'us/las'

      {
        ionoscloud_username: ENV['IONOS_USERNAME'],
        ionoscloud_password: ENV['IONOS_PASSWORD'],
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
