require 'spec_helper'
require 'profitbricks_server_stop'

Chef::Knife::ProfitbricksServerStop.load_deps

describe Chef::Knife::ProfitbricksServerStop do
  subject { Chef::Knife::ProfitbricksServerStop.new }

  before :each do
    @datacenter = create_test_datacenter()

    allow(subject).to receive(:puts)
  end

  after :each do
    Ionoscloud::DataCenterApi.new.datacenters_delete_with_http_info(@datacenter.id)
  end

  describe '#run' do
    it 'should output that the server is stopping when correct ID' do
      @server = create_test_server(@datacenter)
      subject.name_args = [@server.id]
      {
        profitbricks_username: ENV['IONOS_USERNAME'],
        profitbricks_password: ENV['IONOS_PASSWORD'],
        datacenter_id: @datacenter.id,
      }.each do |key, value|
        subject.config[key] = value
      end

      expect(subject.ui).to receive(:warn).with(
        /Server #{@server.id} is stopping. Request ID: (\b[0-9a-f]{8}\b-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-\b[0-9a-f]{12})\b/,
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

      expect(server.properties.vm_state).to eq('SHUTOFF')
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
