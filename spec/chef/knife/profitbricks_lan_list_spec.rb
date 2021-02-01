require 'spec_helper'
require 'profitbricks_lan_list'

Chef::Knife::ProfitbricksLanList.load_deps

describe Chef::Knife::ProfitbricksLanList do
  subject { Chef::Knife::ProfitbricksLanList.new }

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

    {
      profitbricks_username: ENV['IONOS_USERNAME'],
      profitbricks_password: ENV['IONOS_PASSWORD'],
      datacenter_id: @datacenter.id,
    }.each do |key, value|
      subject.config[key] = value
    end
    allow(subject).to receive(:puts)
  end

  describe '#run' do
    it 'should output the column headers and the lan' do
      expect(subject).to receive(:puts).with(
        /^ID\s+Name\s+Public\s*$\n#{@lan.id}\s+#{@lan.properties.name}\s+#{@lan.properties.public}\s*$/,
      )
      subject.run
    end
  end
end
