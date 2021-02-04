require 'spec_helper'
require 'profitbricks_datacenter_delete'

Chef::Knife::ProfitbricksDatacenterDelete.load_deps

describe Chef::Knife::ProfitbricksDatacenterDelete do
  subject { Chef::Knife::ProfitbricksDatacenterDelete.new }

  after :each do
    begin
      Ionoscloud::DataCenterApi.new.datacenters_delete(@datacenter.id)
    rescue Exception
    end
  end

  describe '#run' do
    it 'should delete a data center when yes' do
      @datacenter = create_test_datacenter()

      {
        profitbricks_username: ENV['IONOS_USERNAME'],
        profitbricks_password: ENV['IONOS_PASSWORD'],
      }.each do |key, value|
        subject.config[key] = value
      end
  
      subject.name_args = [@datacenter.id]

      allow(subject).to receive(:puts)
      allow(subject.ui).to receive(:warn)
      allow(subject).to receive(:confirm)

      expect(subject.ui).to receive(:warn).with(
        /Deleted Data center #{@datacenter.id}. Request ID: (\b[0-9a-f]{8}\b-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-\b[0-9a-f]{12})\b/,
      ) do |arg|
        @request_id = arg.split('Request ID: ').last
      end

      expect(subject).to receive(:puts).with("ID: #{@datacenter.id}")
      expect(subject).to receive(:puts).with("Name: #{@datacenter.properties.name}")
      expect(subject).to receive(:puts).with("Description: #{@datacenter.properties.description}")
      expect(subject).to receive(:puts).with("Location: #{@datacenter.properties.location}")
      expect(subject).to receive(:puts).with("Version: #{@datacenter.properties.version}")

      subject.run

      raise Exception.new 'No Request ID found.' unless @request_id

      request = Ionoscloud::RequestApi.new.requests_status_get(@request_id)

      expect(request.metadata.status).to eq('QUEUED').or(eq('DONE'))
      expect(request.metadata.message).to eq('Request has been queued').or(eq('Request has been successfully executed'))
      expect(request.metadata.targets.length).to eq(1)
      expect(request.metadata.targets.first.target.type).to eq('datacenter')
      expect(request.metadata.targets.first.target.id).to eq(@datacenter.id)

      Ionoscloud::ApiClient.new.wait_for { is_done? @request_id }
      
      expect { Ionoscloud::DataCenterApi.new.datacenters_find_by_id(@datacenter.id) }.to raise_error(Ionoscloud::ApiError) do |error|
        expect(error.code).to eq(404)
      end
    end

    it 'should print a message when wrong ID' do
      {
        profitbricks_username: ENV['IONOS_USERNAME'],
        profitbricks_password: ENV['IONOS_PASSWORD'],
      }.each do |key, value|
        subject.config[key] = value
      end
      wrong_datacenter_ids = [123,]
      subject.name_args = wrong_datacenter_ids
      
      expect(subject.ui).not_to receive(:warn)
      wrong_datacenter_ids.each {
        |wrong_datacenter_id|
        expect(subject.ui).to receive(:error).with("Data center ID #{wrong_datacenter_id} not found. Skipping.")
      }

      subject.run
    end
  end
end
