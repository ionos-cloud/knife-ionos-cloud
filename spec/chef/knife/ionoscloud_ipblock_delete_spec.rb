require 'spec_helper'
require 'ionoscloud_ipblock_delete'

Chef::Knife::IonoscloudIpblockDelete.load_deps

describe Chef::Knife::IonoscloudIpblockDelete do
  subject { Chef::Knife::IonoscloudIpblockDelete.new }

  before :each do
    allow(subject).to receive(:puts)
    allow(subject).to receive(:confirm)
    allow(subject.ui).to receive(:warn)
  end

  after :each do
    begin
      Ionoscloud::IPBlocksApi.new.ipblocks_delete(@ip_block.id)
    rescue Exception
    end
  end

  describe '#run' do
    it 'should release the ip block' do
      @ip_block = create_test_ipblock()
  
      {
        ionoscloud_username: ENV['IONOS_USERNAME'],
        ionoscloud_password: ENV['IONOS_PASSWORD'],
      }.each do |key, value|
        subject.config[key] = value
      end
      subject.name_args = [@ip_block.id]

      expect(subject.ui).to receive(:warn).with(
        /Released IP block #{@ip_block.id}. Request ID: (\b[0-9a-f]{8}\b-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-\b[0-9a-f]{12})\b/,
      ) do |arg|
        @request_id = arg.split('Request ID: ').last
      end

      expect(subject).to receive(:puts).with("ID: #{@ip_block.id}")
      expect(subject).to receive(:puts).with("Location: #{@ip_block.properties.location}")
      expect(subject).to receive(:puts).with("IP Addresses: #{@ip_block.properties.ips.to_s}")

      subject.run

      raise Exception.new 'No Request ID found.' unless @request_id

      request = Ionoscloud::RequestApi.new.requests_status_get(@request_id)

      expect(request.metadata.status).to eq('QUEUED').or(eq('DONE'))
      expect(request.metadata.message).to eq('Request has been queued').or(eq('Request has been successfully executed'))
      expect(request.metadata.targets.length).to eq(1)
      expect(request.metadata.targets.first.target.type).to eq('ipblock')
      expect(request.metadata.targets.first.target.id).to eq(@ip_block.id)

      Ionoscloud::ApiClient.new.wait_for { is_done? @request_id }
      
      expect { Ionoscloud::IPBlocksApi.new.ipblocks_find_by_id(@ip_block.id) }.to raise_error(Ionoscloud::ApiError) do |error|
        expect(error.code).to eq(404)
      end
    end

    it 'should print a message when wrong ID' do
      {
        ionoscloud_username: ENV['IONOS_USERNAME'],
        ionoscloud_password: ENV['IONOS_PASSWORD'],
      }.each do |key, value|
        subject.config[key] = value
      end
      wrong_ipblock_ids = [123,]
      subject.name_args = wrong_ipblock_ids

      expect(subject.ui).not_to receive(:warn)
      wrong_ipblock_ids.each {
        |wrong_ipblock_id|
        expect(subject.ui).to receive(:error).with("IP block ID #{wrong_ipblock_id} not found. Skipping.")
      }
      subject.run
    end
  end
end
