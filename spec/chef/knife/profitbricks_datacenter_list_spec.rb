require 'spec_helper'
require 'profitbricks_datacenter_list'

Chef::Knife::ProfitbricksDatacenterList.load_deps

describe Chef::Knife::ProfitbricksDatacenterList do
  subject { Chef::Knife::ProfitbricksDatacenterList.new }

  before :each do
    Ionoscloud.configure do |config|
      config.username = ENV['IONOS_USERNAME']
      config.password = ENV['IONOS_PASSWORD']
    end

    @datacenter_name = 'Chef test'
    @description = 'Chef test datacenter'
    @location = 'us/las'

    @datacenter, _, headers  = Ionoscloud::DataCenterApi.new.datacenters_post_with_http_info({
      properties: {
        name: @datacenter_name,
        description: @description,
        location: @location,
      },
    })
    Ionoscloud::ApiClient.new.wait_for { is_done? get_request_id headers }

    {
      profitbricks_username: ENV['IONOS_USERNAME'],
      profitbricks_password: ENV['IONOS_PASSWORD'],
    }.each do |key, value|
      subject.config[key] = value
    end
    allow(subject).to receive(:puts)
  end

  after :each do
    Ionoscloud::DataCenterApi.new.datacenters_delete(@datacenter.id)
  end

  describe '#run' do
    it 'should output the column headers and the datacenter' do
      expect(subject).to receive(:puts).with(
        /^ID\s+Name\s+Description\s+Location\s+Version\s*$\n#{@datacenter.id}\s+#{@datacenter_name}\s+#{@description}\s+#{@location}\s+1\s*$/,
      )
      subject.run
    end
  end
end
