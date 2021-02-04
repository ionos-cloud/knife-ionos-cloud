require 'spec_helper'
require 'profitbricks_lan_list'

Chef::Knife::ProfitbricksLanList.load_deps

describe Chef::Knife::ProfitbricksLanList do
  subject { Chef::Knife::ProfitbricksLanList.new }

  before :each do
    @datacenter = create_test_datacenter()
    @lan = create_test_lan(@datacenter)
  end

  after :each do
    Ionoscloud::DataCenterApi.new.datacenters_delete_with_http_info(@datacenter.id)
  end

  describe '#run' do
    it 'should output the column headers and the lan' do
      {
        profitbricks_username: ENV['IONOS_USERNAME'],
        profitbricks_password: ENV['IONOS_PASSWORD'],
        datacenter_id: @datacenter.id,
      }.each do |key, value|
        subject.config[key] = value
      end
      allow(subject).to receive(:puts)

      expect(subject).to receive(:puts).with(
        /^ID\s+Name\s+Public\s*$\n#{@lan.id}\s+#{@lan.properties.name}\s+#{@lan.properties.public}\s*$/,
      )
      subject.run
    end
  end
end
