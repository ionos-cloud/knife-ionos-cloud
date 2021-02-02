require 'spec_helper'
require 'profitbricks_datacenter_delete'

Chef::Knife::ProfitbricksDatacenterDelete.load_deps

describe Chef::Knife::ProfitbricksDatacenterDelete do
  subject { Chef::Knife::ProfitbricksDatacenterDelete.new }

  before :each do
    Ionoscloud.configure do |config|
      config.username = ENV['IONOS_USERNAME']
      config.password = ENV['IONOS_PASSWORD']
    end

    @datacenter, _, headers  = Ionoscloud::DataCenterApi.new.datacenters_post_with_http_info({
      properties: {
        name: 'Chef test',
        description: 'Chef test datacenter',
        location:'us/las',
      },
    })
    Ionoscloud::ApiClient.new.wait_for { is_done? get_request_id headers }

    allow(subject).to receive(:puts)
    allow(subject.ui).to receive(:warn)
    allow(subject.ui).to receive(:confirm)
  end

  after :each do
    begin
      Ionoscloud::DataCenterApi.new.datacenters_delete(@datacenter.id)
    rescue Exception
    end
  end

  describe '#run' do
    it 'should delete a data center when yes' do
      {
        profitbricks_username: ENV['IONOS_USERNAME'],
        profitbricks_password: ENV['IONOS_PASSWORD'],
      }.each do |key, value|
        subject.config[key] = value
      end
  
      subject.config[:yes] = true
      subject.name_args = [@datacenter.id]

      expect(subject).to receive(:puts).with("Name: #{@datacenter.properties.name}")
      expect(subject).to receive(:puts).with("Description: #{@datacenter.properties.description}")
      expect(subject).to receive(:puts).with("Location: #{@datacenter.properties.location}")
      subject.run

      sleep(1)
      begin
        Ionoscloud::DataCenterApi.new.datacenters_find_by_id(@datacenter.id)
      rescue Exception => err
        expect(err).to be_a(Ionoscloud::ApiError)
        expect(err.code).to eq(404)
      end
    end
  end
end
