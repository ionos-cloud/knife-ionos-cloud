require 'spec_helper'
require 'profitbricks_firewall_delete'

Chef::Knife::ProfitbricksFirewallDelete.load_deps

describe Chef::Knife::ProfitbricksFirewallDelete do
  subject { Chef::Knife::ProfitbricksFirewallDelete.new }

  before :each do
    @datacenter = create_test_datacenter()
    @server = create_test_server(@datacenter)
    @nic = create_test_nic(@datacenter, @server)

    allow(subject).to receive(:puts)
    allow(subject.ui).to receive(:warn)
    allow(subject).to receive(:confirm)
  end

  after :each do
    Ionoscloud::DataCenterApi.new.datacenters_delete_with_http_info(@datacenter.id)
  end

  describe '#run' do
    it 'should delete a firewall rule when yes' do
      @firewall = create_test_firewall(@datacenter, @server, @nic)

      subject.name_args = [@firewall.id]

      {
        profitbricks_username: ENV['IONOS_USERNAME'],
        profitbricks_password: ENV['IONOS_PASSWORD'],
        datacenter_id: @datacenter.id,
        server_id: @server.id,
        nic_id: @nic.id
      }.each do |key, value|
        subject.config[key] = value
      end

      expect(subject.ui).to receive(:warn).with(
        /Deleted Firewall rule #{@firewall.id}. Request ID: (\b[0-9a-f]{8}\b-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-\b[0-9a-f]{12})\b/,
      ) do |arg|
        @request_id = arg.split('Request ID: ').last
      end

      expect(subject).to receive(:puts).with("ID: #{@firewall.id}")
      expect(subject).to receive(:puts).with("Name: #{@firewall.properties.name}")
      expect(subject).to receive(:puts).with("Protocol: #{@firewall.properties.protocol}")
      expect(subject).to receive(:puts).with("Port Range Start: #{@firewall.properties.port_range_start}")
      expect(subject).to receive(:puts).with("Port Range End: #{@firewall.properties.port_range_end}")

      subject.run

      raise Exception.new 'No Request ID found.' unless @request_id

      request = Ionoscloud::RequestApi.new.requests_status_get(@request_id)

      expect(request.metadata.status).to eq('QUEUED').or(eq('DONE'))
      expect(request.metadata.message).to eq('Request has been queued').or(eq('Request has been successfully executed'))
      expect(request.metadata.targets.length).to eq(1)
      expect(request.metadata.targets.first.target.type).to eq('firewall-rule')
      expect(request.metadata.targets.first.target.id).to eq(@firewall.id)

      Ionoscloud::ApiClient.new.wait_for { is_done? @request_id }
      
      expect {
        Ionoscloud::NicApi.new.datacenters_servers_nics_firewallrules_find_by_id(
          @datacenter.id, @server.id, @nic.id, @firewall.id,
        )
      }.to raise_error(Ionoscloud::ApiError) do |error|
        expect(error.code).to eq(404)
      end
    end

    it 'should print a message when wrong ID' do
      {
        profitbricks_username: ENV['IONOS_USERNAME'],
        profitbricks_password: ENV['IONOS_PASSWORD'],
        datacenter_id: @datacenter.id,
        server_id: @server.id,
        nic_id: @nic.id
      }.each do |key, value|
        subject.config[key] = value
      end
      wrong_firewall_rule_ids = [123,]  
      subject.name_args = wrong_firewall_rule_ids

      expect(subject.ui).not_to receive(:warn)
      wrong_firewall_rule_ids.each {
        |wrong_firewall_rule_id|
        expect(subject.ui).to receive(:error).with("Firewall rule ID #{wrong_firewall_rule_id} not found. Skipping.")
      }
      subject.run
    end
  end
end
