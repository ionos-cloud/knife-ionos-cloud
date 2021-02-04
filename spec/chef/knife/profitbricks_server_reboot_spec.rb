require 'spec_helper'
require 'profitbricks_server_reboot'

Chef::Knife::ProfitbricksServerReboot.load_deps

describe Chef::Knife::ProfitbricksServerReboot do
  subject { Chef::Knife::ProfitbricksServerReboot.new }

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
  end

  after :each do
    Ionoscloud::DataCenterApi.new.datacenters_delete_with_http_info(@datacenter.id)
  end

  describe '#run' do
    it 'should output that the server is rebooting when correct ID and server is running' do
      {
        profitbricks_username: ENV['IONOS_USERNAME'],
        profitbricks_password: ENV['IONOS_PASSWORD'],
        datacenter_id: @datacenter.id,
      }.each do |key, value|
        subject.config[key] = value
      end
      subject.name_args = [@server.id]

      expect(subject.ui).to receive(:warn).with(
        /Server #{@server.id} is rebooting. Request ID: (\b[0-9a-f]{8}\b-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-\b[0-9a-f]{12})\b/,
      ) do |arg|
        @request_id = arg.split('Request ID: ').last
      end

      subject.run

      raise Exception.new 'No Request ID found.' unless @request_id

      request = Ionoscloud::RequestApi.new.requests_status_get(@request_id)

      expect(request.metadata.status).to eq('QUEUED').or(eq('DONE'))
      expect(request.metadata.message).to eq('Request has been queued').or(eq('Request has been successfully executed'))
      expect(request.metadata.targets.length).to eq(1)
      expect(request.metadata.targets.first.target.type).to eq('server')
      expect(request.metadata.targets.first.target.id).to eq(@server.id)

      Ionoscloud::ApiClient.new.wait_for { is_done? @request_id }
      
      server = Ionoscloud::ServerApi.new.datacenters_servers_find_by_id(
        @datacenter.id, @server.id,
      )

      expect(server.properties.vm_state).to eq('RUNNING')
    end


    it 'should output that the server is rebooting when correct ID and server is stopped' do
      _, _, headers = Ionoscloud::ServerApi.new.datacenters_servers_stop_post_with_http_info(@datacenter.id, @server.id)
      Ionoscloud::ApiClient.new.wait_for { is_done? get_request_id headers }

      {
        profitbricks_username: ENV['IONOS_USERNAME'],
        profitbricks_password: ENV['IONOS_PASSWORD'],
        datacenter_id: @datacenter.id,
      }.each do |key, value|
        subject.config[key] = value
      end
      subject.name_args = [@server.id]

      expect(subject.ui).to receive(:warn).with(
        /Server #{@server.id} is rebooting. Request ID: (\b[0-9a-f]{8}\b-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-\b[0-9a-f]{12})\b/,
      ) do |arg|
        @request_id = arg.split('Request ID: ').last
      end

      subject.run

      raise Exception.new 'No Request ID found.' unless @request_id

      request = Ionoscloud::RequestApi.new.requests_status_get(@request_id)

      expect(request.metadata.status).to eq('QUEUED').or(eq('DONE'))
      expect(request.metadata.message).to eq('Request has been queued').or(eq('Request has been successfully executed'))
      expect(request.metadata.targets.length).to eq(1)
      expect(request.metadata.targets.first.target.type).to eq('server')
      expect(request.metadata.targets.first.target.id).to eq(@server.id)

      Ionoscloud::ApiClient.new.wait_for { is_done? @request_id }
      
      server = Ionoscloud::ServerApi.new.datacenters_servers_find_by_id(
        @datacenter.id, @server.id,
      )

      expect(server.properties.vm_state).to eq('RUNNING')
    end

    it 'should print a message when wrong ID' do
      {
        profitbricks_username: ENV['IONOS_USERNAME'],
        profitbricks_password: ENV['IONOS_PASSWORD'],
        datacenter_id: @datacenter.id,
      }.each do |key, value|
        subject.config[key] = value
      end
      wrong_server_ids = [123,]  
      subject.name_args = wrong_server_ids

      expect(subject.ui).not_to receive(:warn)
      wrong_server_ids.each {
        |wrong_server_id|
        expect(subject.ui).to receive(:error).with("Server ID #{wrong_server_id} not found. Skipping.")
      }
      subject.run
    end
  end
end
