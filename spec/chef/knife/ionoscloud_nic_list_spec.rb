require 'spec_helper'
require 'ionoscloud_nic_list'

Chef::Knife::IonoscloudNicList.load_deps

describe Chef::Knife::IonoscloudNicList do
  subject { Chef::Knife::IonoscloudNicList.new }

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
        ionoscloud_username: ENV['IONOS_USERNAME'],
        ionoscloud_password: ENV['IONOS_PASSWORD'],
        datacenter_id: @datacenter.id,
        server_id: @server.id,
      }.each do |key, value|
        subject.config[key] = value
      end

      expect(subject).to receive(:puts).with(
        %r{
          (^ID\s+Name\s+IPs\s+DHCP\s+NAT\s+LAN\s*$\n#{@nic.id}\s+
            #{@nic.properties.name.gsub(' ', '\s')}\s+\[\"#{@nic.properties.ips.first.to_s}\"\]
            \s+#{@nic.properties.dhcp}\s+#{@nic.properties.nat}\s+#{@nic.properties.lan}\s*$)
        }x
      )
      subject.run
    end
  end
end
