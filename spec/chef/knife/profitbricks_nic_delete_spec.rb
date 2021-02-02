require 'spec_helper'
require 'profitbricks_nic_delete'

Chef::Knife::ProfitbricksNicDelete.load_deps

describe Chef::Knife::ProfitbricksNicDelete do
  subject { Chef::Knife::ProfitbricksNicDelete.new }

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

    @server, _, headers  = Ionoscloud::ServerApi.new.datacenters_servers_post_with_http_info(
      @datacenter.id,
      {
        properties: {
          name: 'Chef test Server',
          ram: 1024,
          cores: 1,
          availabilityZone: 'ZONE_1',
          cpuFamily: 'INTEL_SKYLAKE',
        },
      },
    )
    Ionoscloud::ApiClient.new.wait_for { is_done? get_request_id headers }

    @nic, _, headers  = Ionoscloud::NicApi.new.datacenters_servers_nics_post_with_http_info(
      @datacenter.id,
      @server.id,
      {
        properties: {
          name: 'Chef Test',
          dhcp: true,
          lan: 1,
          firewallActive: true,
          nat: false,
        },
      },
    )
    Ionoscloud::ApiClient.new.wait_for { is_done? get_request_id headers }

    @nic = Ionoscloud::NicApi.new.datacenters_servers_nics_find_by_id(
      @datacenter.id, @server.id, @nic.id,
    )
    allow(subject).to receive(:confirm)
    allow(subject).to receive(:puts)
  end

  after :each do
    _, _, headers  = Ionoscloud::DataCenterApi.new.datacenters_delete_with_http_info(@datacenter.id)
  end

  describe '#run' do
    it 'should delete a nic' do
      subject.name_args = [@nic.id]
      {
        profitbricks_username: ENV['IONOS_USERNAME'],
        profitbricks_password: ENV['IONOS_PASSWORD'],
        datacenter_id: @datacenter.id,
        server_id: @server.id,
      }.each do |key, value|
        subject.config[key] = value
      end
  
      subject.config[:yes] = true

      expect(subject).to receive(:puts).with("ID: #{@nic.id}")
      expect(subject).to receive(:puts).with("Name: #{@nic.properties.name}")
      expect(subject).to receive(:puts).with("IPs: #{@nic.properties.ips}")
      expect(subject).to receive(:puts).with("DHCP: #{@nic.properties.dhcp}")
      expect(subject).to receive(:puts).with("LAN: #{@nic.properties.lan}")
      expect(subject).to receive(:puts).with("NAT: #{@nic.properties.nat}")

      subject.run
    end
  end
end
