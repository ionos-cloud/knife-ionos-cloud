require 'spec_helper'
require 'ionoscloud_networkloadbalancer_rule_target_add'

Chef::Knife::IonoscloudNetworkloadbalancerRuleTargetAdd.load_deps

describe Chef::Knife::IonoscloudNetworkloadbalancerRuleTargetAdd do
  before :each do
    subject { Chef::Knife::IonoscloudNetworkloadbalancerRuleTargetAdd.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call NetworkLoadBalancersApi.datacenters_networkloadbalancers_forwardingrules_patch_with_http_info' do
      network_loadbalancer = network_loadbalancer_mock
      network_loadbalancer_rule = network_loadbalancer_rule_mock
      network_loadbalancer_rule_target = network_loadbalancer_rule_target_mock(
        port: 123, ip: '1.1.1.1', check_interval: 2345, maintenance: true, check: false, weight: 13,
      )
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        network_loadbalancer_id: network_loadbalancer.id,
        forwarding_rule_id: network_loadbalancer_rule.id,
        ip: network_loadbalancer_rule_target.ip,
        port: network_loadbalancer_rule_target.port,
        weight: network_loadbalancer_rule_target.weight,
        check: network_loadbalancer_rule_target.health_check.check,
        check_interval: network_loadbalancer_rule_target.health_check.check_interval,
        maintenance: network_loadbalancer_rule_target.health_check.maintenance,
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{network_loadbalancer_rule.id}")
      expect(subject).to receive(:puts).with("Name: #{network_loadbalancer_rule.properties.name}")
      expect(subject).to receive(:puts).with("Algorithm: #{network_loadbalancer_rule.properties.algorithm}")
      expect(subject).to receive(:puts).with("Protocol: #{network_loadbalancer_rule.properties.protocol}")
      expect(subject).to receive(:puts).with("Listener IP: #{network_loadbalancer_rule.properties.listener_ip}")
      expect(subject).to receive(:puts).with("Listener Port: #{network_loadbalancer_rule.properties.listener_port}")
      expect(subject).to receive(:puts).with("Health Check: #{network_loadbalancer_rule.properties.health_check}")
      expect(subject).to receive(:puts).with("Targets: #{
        (network_loadbalancer_rule.properties.targets + [network_loadbalancer_rule_target]).map do |target|
        {
          ip: target.ip,
          port: target.port,
          weight: target.weight,
          check: target.health_check.check,
          check_interval: target.health_check.check_interval,
          maintenance: target.health_check.maintenance,
        }
      end}")

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/networkloadbalancers/#{subject_config[:network_loadbalancer_id]}"\
            "/forwardingrules/#{subject_config[:forwarding_rule_id]}",
            operation: :'NetworkLoadBalancersApi.datacenters_networkloadbalancers_forwardingrules_find_by_forwarding_rule_id',
            return_type: 'NetworkLoadBalancerForwardingRule',
            result: network_loadbalancer_rule,
          },
          {
            method: 'PATCH',
            path: "/datacenters/#{subject_config[:datacenter_id]}/networkloadbalancers/#{subject_config[:network_loadbalancer_id]}"\
            "/forwardingrules/#{subject_config[:forwarding_rule_id]}",
            operation: :'NetworkLoadBalancersApi.datacenters_networkloadbalancers_forwardingrules_patch',
            body: { targets: (network_loadbalancer_rule.properties.targets + [network_loadbalancer_rule_target]).map { |target| target.to_hash } },
            return_type: 'NetworkLoadBalancerForwardingRule',
          },
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/networkloadbalancers/#{subject_config[:network_loadbalancer_id]}"\
            "/forwardingrules/#{subject_config[:forwarding_rule_id]}",
            operation: :'NetworkLoadBalancersApi.datacenters_networkloadbalancers_forwardingrules_find_by_forwarding_rule_id',
            return_type: 'NetworkLoadBalancerForwardingRule',
            result: network_loadbalancer_rule,
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
