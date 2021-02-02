require 'spec_helper'
require 'profitbricks_server_start'

Chef::Knife::ProfitbricksServerStart.load_deps

describe Chef::Knife::ProfitbricksServerStart do
  subject { Chef::Knife::ProfitbricksServerStart.new }

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

    Chef::Config[:knife][:datacenter_id] = @datacenter.id
    subject.name_args = [@server.id]

    allow(subject).to receive(:puts)
  end

  after :each do
    Ionoscloud::DataCenterApi.new.datacenters_delete_with_http_info(@datacenter.id)
  end

  describe '#run' do
    it 'should output that the server is starting when correct ID' do
      {
        profitbricks_username: ENV['IONOS_USERNAME'],
        profitbricks_password: ENV['IONOS_PASSWORD'],
        datacenter_id: @datacenter.id,
      }.each do |key, value|
        subject.config[key] = value
      end
      subject.name_args = [@server.id]

      expect(subject.ui).to receive(:warn).with("Server #{@server.id} is starting")

      subject.run
    end
    it 'should output an error when wrong ID' do
      server_id = 1
      {
        profitbricks_username: ENV['IONOS_USERNAME'],
        profitbricks_password: ENV['IONOS_PASSWORD'],
        datacenter_id: @datacenter.id,
      }.each do |key, value|
        subject.config[key] = value
      end
      subject.name_args = [server_id]

      expect(subject.ui).to receive(:error).with("Server ID #{server_id} not found. Skipping.")

      subject.run
    end
  end
end
