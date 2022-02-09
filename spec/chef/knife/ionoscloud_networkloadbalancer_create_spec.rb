require 'spec_helper'
require 'ionoscloud_networkloadbalancer_create'

Chef::Knife::IonoscloudNetworkloadbalancerCreate.load_deps

describe Chef::Knife::IonoscloudNetworkloadbalancerCreate do
  before :each do
    subject { Chef::Knife::IonoscloudNetworkloadbalancerCreate.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call NetworkLoadBalancersApi.datacenters_networkloadbalancers_post with the expected arguments and output based on what it receives' do
      network_loadbalancer = network_loadbalancer_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        name: network_loadbalancer.properties.name,
        ips: network_loadbalancer.properties.ips.join(','),
        listener_lan: network_loadbalancer.properties.listener_lan,
        target_lan: network_loadbalancer.properties.target_lan,
        lb_private_ips: network_loadbalancer.properties.lb_private_ips.join(','),
      }.each do |key, value|
        subject.config[key] = value
      end

      expect(subject).to receive(:puts).with("ID: #{network_loadbalancer.id}")
      expect(subject).to receive(:puts).with("Name: #{network_loadbalancer.properties.name}")
      expect(subject).to receive(:puts).with("Listener LAN: #{network_loadbalancer.properties.listener_lan}")
      expect(subject).to receive(:puts).with("IPS: #{network_loadbalancer.properties.ips}")
      expect(subject).to receive(:puts).with("Target LAN: #{network_loadbalancer.properties.target_lan}")
      expect(subject).to receive(:puts).with("Private IPS: #{network_loadbalancer.properties.lb_private_ips}")
      expect(subject).to receive(:puts).with("Forwarding Rules: #{network_loadbalancer.entities.forwardingrules.items.map do |rule|
        {
          id: rule.id,
          name: rule.properties.name,
          algorithm: rule.properties.algorithm,
          protocol: rule.properties.protocol,
          listener_ip: rule.properties.listener_ip,
          listener_port: rule.properties.listener_port,
          health_check: rule.properties.health_check.nil? ? nil : rule.properties.health_check.to_hash,
          targets: (rule.properties.targets.nil? ? [] : rule.properties.targets.map { |target| target.to_hash }),
        }
      end}")
      expect(subject).to receive(:puts).with("Flowlogs: #{network_loadbalancer.entities.flowlogs.items.map { |flowlog| flowlog.id }}")

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'POST',
            path: "/datacenters/#{subject_config[:datacenter_id]}/networkloadbalancers",
            operation: :'NetworkLoadBalancersApi.datacenters_networkloadbalancers_post',
            return_type: 'NetworkLoadBalancer',
            body: { properties: network_loadbalancer.properties.to_hash },
            result: network_loadbalancer,
          },
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/networkloadbalancers/#{network_loadbalancer.id}",
            operation: :'NetworkLoadBalancersApi.datacenters_networkloadbalancers_find_by_network_load_balancer_id',
            return_type: 'NetworkLoadBalancer',
            result: network_loadbalancer,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not make any call if any required option is missing' do
      check_required_options(subject)
    end
  end
end
