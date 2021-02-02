require 'spec_helper'
require 'profitbricks_server_delete'

Chef::Knife::ProfitbricksServerDelete.load_deps

describe Chef::Knife::ProfitbricksServerDelete do
  subject { Chef::Knife::ProfitbricksServerDelete.new }

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

    @server, _, headers  = Ionoscloud::ServerApi.new.datacenters_servers_post_with_http_info(
      @datacenter.id,
      {
        properties: {
          name: 'Chef test Server',
          ram: 1024,
          cores: 1,
          availabilityZone: 'ZONE_1',
          cpuFamily: 'INTEL_SKYLAKE',
        },
      },
    )
    Ionoscloud::ApiClient.new.wait_for { is_done? get_request_id headers }

    allow(subject).to receive(:puts)
    allow(subject.ui).to receive(:warn)
    allow(subject.ui).to receive(:confirm)
  end

  after :each do
    Ionoscloud::DataCenterApi.new.datacenters_delete_with_http_info(@datacenter.id)
  end

  describe '#run' do
    it 'should delete a server when yes' do
      {
        profitbricks_username: ENV['IONOS_USERNAME'],
        profitbricks_password: ENV['IONOS_PASSWORD'],
        datacenter_id: @datacenter.id,
      }.each do |key, value|
        subject.config[key] = value
      end

      subject.name_args = [@server.id]
      subject.config[:yes] = true

      expect(subject).to receive(:puts).with("ID: #{@server.id}")
      expect(subject).to receive(:puts).with("Name: #{@server.properties.name}")
      expect(subject).to receive(:puts).with("Cores: #{@server.properties.cores}")
      expect(subject).to receive(:puts).with("RAM: #{@server.properties.ram}")
      expect(subject).to receive(:puts).with("Availability Zone: #{@server.properties.availability_zone}")

      subject.run
    end
  end
end
