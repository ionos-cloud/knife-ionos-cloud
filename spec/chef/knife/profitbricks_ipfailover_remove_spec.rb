require 'spec_helper'
require 'profitbricks_ipfailover_remove'

Chef::Knife::ProfitbricksIpfailoverRemove.load_deps

describe Chef::Knife::ProfitbricksIpfailoverRemove do
  subject { Chef::Knife::ProfitbricksIpfailoverRemove.new }

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

    @server, _, server_headers  = Ionoscloud::ServerApi.new.datacenters_servers_post_with_http_info(
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

    @ip_block, _, ip_block_headers = Ionoscloud::IPBlocksApi.new.ipblocks_post_with_http_info(
      {
        properties: {
          location: 'de/fra',
          size: 1,
        },
      },
    )

    @lan, _, lan_headers  = Ionoscloud::LanApi.new.datacenters_lans_post_with_http_info(
      @datacenter.id,
      {
        properties: {
          name: 'Chef test Lan',
          public: true,
      },
    })

    Ionoscloud::ApiClient.new.wait_for { is_done? get_request_id lan_headers }
    Ionoscloud::ApiClient.new.wait_for { is_done? get_request_id ip_block_headers }
    Ionoscloud::ApiClient.new.wait_for { is_done? get_request_id server_headers }

    @nic, _, headers  = Ionoscloud::NicApi.new.datacenters_servers_nics_post_with_http_info(
      @datacenter.id,
      @server.id,
      {
        properties: {
          name: 'Chef Test',
          dhcp: true,
          lan: @lan.id,
          firewallActive: true,
          nat: false,
          ips: [@ip_block.properties.ips.first]
        },
      },
    )
    Ionoscloud::ApiClient.new.wait_for { is_done? get_request_id headers }

    failover_ips = [{
      ip: @ip_block.properties.ips.first,
      nicUuid: @nic.id,
    }]

    changes = Ionoscloud::LanProperties.new({ ip_failover: failover_ips })

    _, _, headers = Ionoscloud::LanApi.new.datacenters_lans_patch_with_http_info(@datacenter.id, @lan.id, changes)
    Ionoscloud::ApiClient.new.wait_for { is_done? get_request_id headers }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  after :each do
    _, _, headers = Ionoscloud::DataCenterApi.new.datacenters_delete_with_http_info(@datacenter.id)
    Ionoscloud::ApiClient.new.wait_for { is_done? get_request_id headers }
    Ionoscloud::IPBlocksApi.new.ipblocks_delete(@ip_block.id)
  end

  describe '#run' do
    it 'should renive ip failover' do
      {
        profitbricks_username: ENV['IONOS_USERNAME'],
        profitbricks_password: ENV['IONOS_PASSWORD'],
        datacenter_id: @datacenter.id,
        nic_id: @nic.id,
        lan_id: @lan.id,
        ip: @ip_block.properties.ips.first
      }.each do |key, value|
        subject.config[key] = value
      end

      expect(subject).to receive(:puts).with("ID: #{@lan.id}")
      expect(subject).to receive(:puts).with("Name: #{@lan.properties.name}")
      expect(subject).to receive(:puts).with("Public: #{@lan.properties.public}")
      expect(subject).to receive(:puts).with("IP Failover: #{[]}")

      expect(Ionoscloud::LanApi.new.datacenters_lans_find_by_id(@datacenter.id, @lan.id).properties.ip_failover.length).to eq(1)
      
      subject.run

      expect(Ionoscloud::LanApi.new.datacenters_lans_find_by_id(@datacenter.id, @lan.id).properties.ip_failover.length).to eq(0)
    end
  end
end
