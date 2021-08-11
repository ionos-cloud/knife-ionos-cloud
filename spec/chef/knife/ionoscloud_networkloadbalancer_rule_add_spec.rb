require 'spec_helper'
require 'ionoscloud_networkloadbalancer_rule_add'

Chef::Knife::IonoscloudNetworkloadbalancerRuleAdd.load_deps

describe Chef::Knife::IonoscloudNetworkloadbalancerRuleAdd do
  before :each do
    subject { Chef::Knife::IonoscloudNetworkloadbalancerRuleAdd.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call NetworkLoadBalancersApi.datacenters_networkloadbalancers_forwardingrules_post_with_http_info' do
      network_loadbalancer = network_loadbalancer_mock
      network_loadbalancer_rule = network_loadbalancer_rule_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        network_loadbalancer_id: network_loadbalancer.id,
        name: network_loadbalancer_rule.properties.name,
        algorithm: network_loadbalancer_rule.properties.algorithm,
        protocol: network_loadbalancer_rule.properties.protocol,
        listener_ip: network_loadbalancer_rule.properties.listener_ip,
        listener_port: network_loadbalancer_rule.properties.listener_port,
        client_timeout: network_loadbalancer_rule.properties.health_check.client_timeout,
        connect_timeout: network_loadbalancer_rule.properties.health_check.connect_timeout,
        target_timeout: network_loadbalancer_rule.properties.health_check.target_timeout,
        retries: network_loadbalancer_rule.properties.health_check.retries,
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{network_loadbalancer.id}")
      expect(subject).to receive(:puts).with("Name: #{network_loadbalancer.properties.name}")
      expect(subject).to receive(:puts).with("Listener LAN: #{network_loadbalancer.properties.listener_lan}")
      expect(subject).to receive(:puts).with("IPS: #{network_loadbalancer.properties.ips}")
      expect(subject).to receive(:puts).with("Target LAN: #{network_loadbalancer.properties.target_lan}")
      expect(subject).to receive(:puts).with("Private IPS: #{network_loadbalancer.properties.lb_private_ips}")
      expect(subject).to receive(:puts).with("Forwarding Rules: #{(network_loadbalancer.entities.forwardingrules.items + [network_loadbalancer_rule]).map do |rule|
        {
          id: rule.id,
          name: rule.properties.name,
          algorithm: rule.properties.algorithm,
          protocol: rule.properties.protocol,
          listener_ip: rule.properties.listener_ip,
          listener_port: rule.properties.listener_port,
          health_check: rule.properties.health_check,
          targets: rule.properties.targets,
        }
      end}")

      network_loadbalancer.entities.forwardingrules.items << network_loadbalancer_rule

      expected_properties = network_loadbalancer_rule_mock.properties.to_hash
      expected_properties.delete(:targets)

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'POST',
            path: "/datacenters/#{subject_config[:datacenter_id]}/networkloadbalancers/#{subject_config[:network_loadbalancer_id]}/forwardingrules",
            operation: :'NetworkLoadBalancersApi.datacenters_networkloadbalancers_forwardingrules_post',
            body: { properties: expected_properties },
            return_type: 'NetworkLoadBalancerForwardingRule',
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
      required_options = subject.instance_variable_get(:@required_options)

      arrays_without_one_element(required_options).each do |test_case|

        test_case[:array].each { |value| subject.config[value] = 'test' }

        expect(subject).to receive(:puts).with("Missing required parameters #{test_case[:removed]}")
        expect(subject.api_client).not_to receive(:call_api)

        expect { subject.run }.to raise_error(SystemExit) do |error|
          expect(error.status).to eq(1)
        end

        required_options.each { |value| subject.config[value] = nil }
      end
    end
  end
end
