require 'spec_helper'
require 'profitbricks_nic_delete'

Chef::Knife::ProfitbricksNicDelete.load_deps

describe Chef::Knife::ProfitbricksNicDelete do
  subject { Chef::Knife::ProfitbricksNicDelete.new }

  before :each do
    @datacenter = create_test_datacenter()
    @server = create_test_server(@datacenter)

    allow(subject).to receive(:confirm)
    allow(subject.ui).to receive(:warn)
    allow(subject).to receive(:puts)
  end

  after :each do
    Ionoscloud::DataCenterApi.new.datacenters_delete_with_http_info(@datacenter.id)
  end

  describe '#run' do
    it 'should delete a nic' do
      @nic = create_test_nic(@datacenter, @server)
      subject.name_args = [@nic.id]
      {
        profitbricks_username: ENV['IONOS_USERNAME'],
        profitbricks_password: ENV['IONOS_PASSWORD'],
        datacenter_id: @datacenter.id,
        server_id: @server.id,
      }.each do |key, value|
        subject.config[key] = value
      end

      expect(subject.ui).to receive(:warn).with(
        /Deleted Nic #{@nic.id}. Request ID: (\b[0-9a-f]{8}\b-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-\b[0-9a-f]{12})\b/,
      ) do |arg|
        @request_id = arg.split('Request ID: ').last
      end

      expect(subject).to receive(:puts).with("ID: #{@nic.id}")
      expect(subject).to receive(:puts).with("Name: #{@nic.properties.name}")
      expect(subject).to receive(:puts).with("IPs: #{@nic.properties.ips}")
      expect(subject).to receive(:puts).with("DHCP: #{@nic.properties.dhcp}")
      expect(subject).to receive(:puts).with("LAN: #{@nic.properties.lan}")
      expect(subject).to receive(:puts).with("NAT: #{@nic.properties.nat}")

      subject.run

      raise Exception.new 'No Request ID found.' unless @request_id

      request = Ionoscloud::RequestApi.new.requests_status_get(@request_id)

      expect(request.metadata.status).to eq('QUEUED').or(eq('DONE'))
      expect(request.metadata.message).to eq('Request has been queued').or(eq('Request has been successfully executed'))
      expect(request.metadata.targets.length).to eq(1)
      expect(request.metadata.targets.first.target.type).to eq('nic')
      expect(request.metadata.targets.first.target.id).to eq(@nic.id)

      Ionoscloud::ApiClient.new.wait_for { is_done? @request_id }
      
      expect {
        Ionoscloud::NicApi.new.datacenters_servers_nics_find_by_id(
          @datacenter.id,
          @server.id,
          @nic.id,
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
      }.each do |key, value|
        subject.config[key] = value
      end
      wrong_nic_ids = [123,]  
      subject.name_args = wrong_nic_ids

      expect(subject.ui).not_to receive(:warn)
      wrong_nic_ids.each {
        |wrong_nic_id|
        expect(subject.ui).to receive(:error).with("Nic ID #{wrong_nic_id} not found. Skipping.")
      }
      subject.run
    end
  end
end
