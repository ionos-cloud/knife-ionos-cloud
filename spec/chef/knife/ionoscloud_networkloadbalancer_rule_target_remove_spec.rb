require 'spec_helper'
require 'ionoscloud_networkloadbalancer_rule_target_remove'

Chef::Knife::IonoscloudNetworkloadbalancerRuleTargetRemove.load_deps

describe Chef::Knife::IonoscloudNetworkloadbalancerRuleTargetRemove do
  before :each do
    subject { Chef::Knife::IonoscloudNetworkloadbalancerRuleTargetRemove.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call NetworkLoadBalancersApi.datacenters_networkloadbalancers_forwardingrules_patch_with_http_info' do
      network_loadbalancer = network_loadbalancer_mock
      network_loadbalancer_rule = network_loadbalancer_rule_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        network_loadbalancer_id: network_loadbalancer.id,
        forwarding_rule_id: network_loadbalancer_rule.id,
        ip: network_loadbalancer_rule.properties.targets.first.ip,
        port: network_loadbalancer_rule.properties.targets.first.port,
        yes: true,
      }

      remaining_targets = network_loadbalancer_rule.properties.targets.reject do
        |target|
        target.ip == subject_config[:ip] && target.port == subject_config[:port]
      end

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{network_loadbalancer_rule.id}")
      expect(subject).to receive(:puts).with("Name: #{network_loadbalancer_rule.properties.name}")
      expect(subject).to receive(:puts).with("Algorithm: #{network_loadbalancer_rule.properties.algorithm}")
      expect(subject).to receive(:puts).with("Protocol: #{network_loadbalancer_rule.properties.protocol}")
      expect(subject).to receive(:puts).with("Listener IP: #{network_loadbalancer_rule.properties.listener_ip}")
      expect(subject).to receive(:puts).with("Listener Port: #{network_loadbalancer_rule.properties.listener_port}")
      expect(subject).to receive(:puts).with("Health Check: #{network_loadbalancer_rule.properties.health_check}")
      expect(subject).to receive(:puts).with("Targets: #{remaining_targets.map do |target|
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
            body: { targets: remaining_targets.map { |target| target.to_hash } },
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

    it 'should call NetworkLoadBalancersApi.datacenters_networkloadbalancers_forwardingrules_patch_with_http_info 2' do
      network_loadbalancer = network_loadbalancer_mock
      network_loadbalancer_rule = network_loadbalancer_rule_mock(
        targets: [
          network_loadbalancer_rule_target_mock(
            port: 123, ip: '1.1.1.1', check_interval: 2345, maintenance: true, check: true, weight: 13,
          ),
          network_loadbalancer_rule_target_mock(
            port: 1234, ip: '1.1.122.1', check_interval: 1231, maintenance: true, check: false, weight: 456,
          ),
          network_loadbalancer_rule_target_mock(
            port: 112, ip: '1.133.1.1', check_interval: 2525, maintenance: true, check: true, weight: 425,
          ),
          network_loadbalancer_rule_target_mock(
            port: 123, ip: '1.133.1.1', check_interval: 36346, maintenance: false, check: false, weight: 4,
          ),
          network_loadbalancer_rule_target_mock(
            port: 164, ip: '1.1.1.1', check_interval: 243, maintenance: true, check: false, weight: 123,
          ),
        ]
      )
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        network_loadbalancer_id: network_loadbalancer.id,
        forwarding_rule_id: network_loadbalancer_rule.id,
        ip: network_loadbalancer_rule.properties.targets.first.ip,
        port: network_loadbalancer_rule.properties.targets.first.port,
        yes: true,
      }

      remaining_targets = network_loadbalancer_rule.properties.targets.reject do
        |target|
        target.ip == subject_config[:ip] && target.port == subject_config[:port]
      end

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{network_loadbalancer_rule.id}")
      expect(subject).to receive(:puts).with("Name: #{network_loadbalancer_rule.properties.name}")
      expect(subject).to receive(:puts).with("Algorithm: #{network_loadbalancer_rule.properties.algorithm}")
      expect(subject).to receive(:puts).with("Protocol: #{network_loadbalancer_rule.properties.protocol}")
      expect(subject).to receive(:puts).with("Listener IP: #{network_loadbalancer_rule.properties.listener_ip}")
      expect(subject).to receive(:puts).with("Listener Port: #{network_loadbalancer_rule.properties.listener_port}")
      expect(subject).to receive(:puts).with("Health Check: #{network_loadbalancer_rule.properties.health_check}")
      expect(subject).to receive(:puts).with("Targets: #{remaining_targets.map do |target|
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
            body: { targets: remaining_targets.map { |target| target.to_hash } },
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

    it 'should not call NetworkLoadBalancersApi.datacenters_networkloadbalancers_forwardingrules_patch_with_http_info when no target exists' do
      network_loadbalancer = network_loadbalancer_mock
      network_loadbalancer_rule = network_loadbalancer_rule_mock(
        targets: [
          network_loadbalancer_rule_target_mock(
            port: 123, ip: '1.1.1.1', check_interval: 2345, maintenance: true, check: true, weight: 13,
          ),
        ]
      )
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        network_loadbalancer_id: network_loadbalancer.id,
        forwarding_rule_id: network_loadbalancer_rule.id,
        ip: '1.1.1.2',
        port: 123,
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
      expect(subject).to receive(:puts).with("Targets: #{network_loadbalancer_rule.properties.targets.map do |target|
        {
          ip: target.ip,
          port: target.port,
          weight: target.weight,
          check: target.health_check.check,
          check_interval: target.health_check.check_interval,
          maintenance: target.health_check.maintenance,
        }
      end}")

      expect(subject.api_client).not_to receive(:wait_for)
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
