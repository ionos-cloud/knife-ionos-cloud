require 'spec_helper'
require 'ionoscloud_networkloadbalancer_update'

Chef::Knife::IonoscloudNetworkloadbalancerUpdate.load_deps

describe Chef::Knife::IonoscloudNetworkloadbalancerUpdate do
  before :each do
    subject { Chef::Knife::IonoscloudNetworkloadbalancerUpdate.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call NetworkLoadBalancersApi.datacenters_networkloadbalancers_patch' do
      network_loadbalancer = network_loadbalancer_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        network_loadbalancer_id: network_loadbalancer.id,
        name: network_loadbalancer.properties.name + '_edited',
        listener_lan: Integer(network_loadbalancer.properties.listener_lan) + 1,
        target_lan: Integer(network_loadbalancer.properties.target_lan) + 1,
        ips: (network_loadbalancer.properties.ips + ['127.0.0.3']).join(','),
        lb_private_ips: (network_loadbalancer.properties.lb_private_ips + ['127.0.0.7/24']).join(','),
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{network_loadbalancer.id}")
      expect(subject).to receive(:puts).with("Name: #{subject_config[:name]}")
      expect(subject).to receive(:puts).with("Listener LAN: #{subject_config[:listener_lan]}")
      expect(subject).to receive(:puts).with("IPS: #{subject_config[:ips].split(',')}")
      expect(subject).to receive(:puts).with("Target LAN: #{subject_config[:target_lan]}")
      expect(subject).to receive(:puts).with("Private IPS: #{subject_config[:lb_private_ips].split(',')}")
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

      network_loadbalancer.properties.name = subject_config[:name]
      network_loadbalancer.properties.ips = subject_config[:ips].split(',')
      network_loadbalancer.properties.lb_private_ips = subject_config[:lb_private_ips].split(',')
      network_loadbalancer.properties.listener_lan = subject_config[:listener_lan]
      network_loadbalancer.properties.target_lan = subject_config[:target_lan]

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'PATCH',
            path: "/datacenters/#{subject_config[:datacenter_id]}/networkloadbalancers/#{subject_config[:network_loadbalancer_id]}",
            operation: :'NetworkLoadBalancersApi.datacenters_networkloadbalancers_patch',
            return_type: 'NetworkLoadBalancer',
            body: {
              name: subject_config[:name],
              ips: subject_config[:ips].split(','),
              lbPrivateIps: subject_config[:lb_private_ips].split(','),
              listenerLan: subject_config[:listener_lan],
              targetLan: subject_config[:target_lan],
            },
            result: network_loadbalancer,
          },
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/networkloadbalancers/#{subject_config[:network_loadbalancer_id]}",
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
