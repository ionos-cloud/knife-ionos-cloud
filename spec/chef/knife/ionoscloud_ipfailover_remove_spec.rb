require 'spec_helper'
require 'ionoscloud_ipfailover_remove'

Chef::Knife::IonoscloudIpfailoverRemove.load_deps

describe Chef::Knife::IonoscloudIpfailoverRemove do
  subject { Chef::Knife::IonoscloudIpfailoverRemove.new }

  before :each do
    @datacenter = create_test_datacenter()
    @ip_block = create_test_ipblock()
    @server = create_test_server(@datacenter)
    @lan = create_test_lan(@datacenter)
    @nic = create_test_nic(@datacenter, @server, { lan: @lan.id, ips: [@ip_block.properties.ips.first] })

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
        ionoscloud_username: ENV['IONOS_USERNAME'],
        ionoscloud_password: ENV['IONOS_PASSWORD'],
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
