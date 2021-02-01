require 'spec_helper'
require 'profitbricks_lan_delete'

Chef::Knife::ProfitbricksLanDelete.load_deps

describe Chef::Knife::ProfitbricksLanDelete do
  subject { Chef::Knife::ProfitbricksLanDelete.new }

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

    @lan, _, headers  = Ionoscloud::LanApi.new.datacenters_lans_post_with_http_info(
      @datacenter.id,
      {
        properties: {
          name: 'Chef test Lan',
          public: true,
      },
    })
    Ionoscloud::ApiClient.new.wait_for { is_done? get_request_id headers }

    subject.name_args = [@lan.id]
    {
      profitbricks_username: ENV['IONOS_USERNAME'],
      profitbricks_password: ENV['IONOS_PASSWORD'],
      datacenter_id: @datacenter.id,
    }.each do |key, value|
      subject.config[key] = value
    end

    subject.config[:yes] = true

    allow(subject).to receive(:confirm)
    allow(subject).to receive(:puts)
  end

  after :each do
    _, _, headers  = Ionoscloud::DataCenterApi.new.datacenters_delete_with_http_info(@datacenter.id)
  end

  describe '#run' do
    it 'should delete a lan' do
      expect(subject).to receive(:puts).with("ID: #{@lan.id}")
      expect(subject).to receive(:puts).with("Name: #{@lan.properties.name}")
      expect(subject).to receive(:puts).with("Public: #{@lan.properties.public}")

      subject.run
    end
  end
end
