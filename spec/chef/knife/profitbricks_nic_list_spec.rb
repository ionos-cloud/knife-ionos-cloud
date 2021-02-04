require 'spec_helper'
require 'profitbricks_nic_list'

Chef::Knife::ProfitbricksNicList.load_deps

describe Chef::Knife::ProfitbricksNicList do
  subject { Chef::Knife::ProfitbricksNicList.new }

  before :each do
    @datacenter = create_test_datacenter()
    @server = create_test_server(@datacenter)
    @nic = create_test_nic(@datacenter, @server)

    allow(subject).to receive(:puts)
  end

  after :each do
    Ionoscloud::DataCenterApi.new.datacenters_delete_with_http_info(@datacenter.id)
  end

  describe '#run' do
    it 'should output the column headers and the nic' do
      {
        profitbricks_username: ENV['IONOS_USERNAME'],
        profitbricks_password: ENV['IONOS_PASSWORD'],
        datacenter_id: @datacenter.id,
        server_id: @server.id,
      }.each do |key, value|
        subject.config[key] = value
      end

      expect(subject).to receive(:puts).with(
        %r{(ID\s+Name\s+IPs\s+DHCP\s+NAT\s+LAN\s*$\n#{@nic.id}\s+#{@nic.properties.name}\s+\[\"#{@nic.properties.ips.first.to_s}\"\]\s+#{@nic.properties.dhcp}\s+#{@nic.properties.nat}\s+#{@nic.properties.lan}\s*$)}
      )
      subject.run
    end
  end
end
