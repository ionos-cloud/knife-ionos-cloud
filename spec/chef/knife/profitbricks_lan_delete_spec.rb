require 'spec_helper'
require 'profitbricks_lan_delete'

Chef::Knife::ProfitbricksLanDelete.load_deps

describe Chef::Knife::ProfitbricksLanDelete do
  subject { Chef::Knife::ProfitbricksLanDelete.new }

  before :each do
    @datacenter = create_test_datacenter()

    allow(subject).to receive(:confirm)
    allow(subject.ui).to receive(:warn)
    allow(subject).to receive(:puts)
  end

  after :each do
    Ionoscloud::DataCenterApi.new.datacenters_delete_with_http_info(@datacenter.id)
  end

  describe '#run' do
    it 'should delete a lan' do
      @lan = create_test_lan(@datacenter)
      subject.name_args = [@lan.id]
      {
        profitbricks_username: ENV['IONOS_USERNAME'],
        profitbricks_password: ENV['IONOS_PASSWORD'],
        datacenter_id: @datacenter.id,
      }.each do |key, value|
        subject.config[key] = value
      end

      expect(subject.ui).to receive(:warn).with(
        /Deleted Lan #{@lan.id}. Request ID: (\b[0-9a-f]{8}\b-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-\b[0-9a-f]{12})\b/,
      ) do |arg|
        @request_id = arg.split('Request ID: ').last
      end

      expect(subject).to receive(:puts).with("ID: #{@lan.id}")
      expect(subject).to receive(:puts).with("Name: #{@lan.properties.name}")
      expect(subject).to receive(:puts).with("Public: #{@lan.properties.public}")

      subject.run

      raise Exception.new 'No Request ID found.' unless @request_id

      request = Ionoscloud::RequestApi.new.requests_status_get(@request_id)

      expect(request.metadata.status).to eq('QUEUED').or(eq('DONE'))
      expect(request.metadata.message).to eq('Request has been queued').or(eq('Request has been successfully executed'))
      expect(request.metadata.targets.length).to eq(1)
      expect(request.metadata.targets.first.target.type).to eq('lan')
      expect(request.metadata.targets.first.target.id).to eq(@lan.id)

      Ionoscloud::ApiClient.new.wait_for { is_done? @request_id }
      
      expect {
        Ionoscloud::LanApi.new.datacenters_lans_find_by_id(
          @datacenter.id,
          @lan.id,
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
      }.each do |key, value|
        subject.config[key] = value
      end
      wrong_lan_ids = [123,]  
      subject.name_args = wrong_lan_ids

      expect(subject.ui).not_to receive(:warn)
      wrong_lan_ids.each {
        |wrong_lan_id|
        expect(subject.ui).to receive(:error).with("Lan ID #{wrong_lan_id} not found. Skipping.")
      }
      subject.run
    end
  end
end
