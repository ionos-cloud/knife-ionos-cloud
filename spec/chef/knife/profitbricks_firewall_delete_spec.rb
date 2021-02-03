require 'spec_helper'
require 'profitbricks_firewall_delete'

Chef::Knife::ProfitbricksFirewallDelete.load_deps

describe Chef::Knife::ProfitbricksFirewallDelete do
  subject { Chef::Knife::ProfitbricksFirewallDelete.new }

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

    @firewall, _, headers = Ionoscloud::NicApi.new.datacenters_servers_nics_firewallrules_post_with_http_info(
      @datacenter.id,
      @server.id,
      @nic.id,
      {
        properties: {
          name: 'Chef test Firewall',
          protocol: 'TCP',
          portRangeStart: '22',
          portRangeEnd: '22',
        },
      },
    )
    Ionoscloud::ApiClient.new.wait_for { is_done? get_request_id headers }


    allow(subject).to receive(:puts)
    allow(subject.ui).to receive(:warn)
    allow(subject).to receive(:confirm)
  end

  after :each do
    Ionoscloud::DataCenterApi.new.datacenters_delete_with_http_info(@datacenter.id)
  end

  describe '#run' do
    it 'should delete a firewall rule when yes' do
      subject.name_args = [@firewall.id]

      {
        profitbricks_username: ENV['IONOS_USERNAME'],
        profitbricks_password: ENV['IONOS_PASSWORD'],
        datacenter_id: @datacenter.id,
        server_id: @server.id,
        nic_id: @nic.id
      }.each do |key, value|
        subject.config[key] = value
      end

      subject.config[:yes] = true

      expect(subject).to receive(:puts).with("ID: #{@firewall.id}")
      expect(subject).to receive(:puts).with("Name: #{@firewall.properties.name}")
      expect(subject).to receive(:puts).with("Protocol: #{@firewall.properties.protocol}")
      expect(subject).to receive(:puts).with("Port Range Start: #{@firewall.properties.port_range_start}")
      expect(subject).to receive(:puts).with("Port Range End: #{@firewall.properties.port_range_end}")

      subject.run
    end
  end
end
