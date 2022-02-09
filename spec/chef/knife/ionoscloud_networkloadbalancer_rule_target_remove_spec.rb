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
      network_loadbalancer_rule = network_loadbalancer.entities.forwardingrules.items[0]
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

      fw_rules = network_loadbalancer.entities.forwardingrules.items.map do |rule|
        {
          id: rule.id,
          name: rule.properties.name,
          algorithm: rule.properties.algorithm,
          protocol: rule.properties.protocol,
          listener_ip: rule.properties.listener_ip,
          listener_port: rule.properties.listener_port,
          health_check: rule.properties.health_check.nil? ? nil : rule.properties.health_check.to_hash,
          targets: rule.properties.targets.map { |target| target.to_hash },
        }
      end

      fw_rules[0][:targets] = remaining_targets.map { |target| target.to_hash }

      expect(subject).to receive(:puts).with("ID: #{network_loadbalancer.id}")
      expect(subject).to receive(:puts).with("Name: #{network_loadbalancer.properties.name}")
      expect(subject).to receive(:puts).with("Listener LAN: #{network_loadbalancer.properties.listener_lan}")
      expect(subject).to receive(:puts).with("IPS: #{network_loadbalancer.properties.ips}")
      expect(subject).to receive(:puts).with("Target LAN: #{network_loadbalancer.properties.target_lan}")
      expect(subject).to receive(:puts).with("Private IPS: #{network_loadbalancer.properties.lb_private_ips}")
      expect(subject).to receive(:puts).with("Forwarding Rules: #{fw_rules}")
      expect(subject).to receive(:puts).with("Flowlogs: #{network_loadbalancer.entities.flowlogs.items.map { |flowlog| flowlog.id }}")

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
            path: "/datacenters/#{subject_config[:datacenter_id]}/networkloadbalancers/#{subject_config[:network_loadbalancer_id]}",
            operation: :'NetworkLoadBalancersApi.datacenters_networkloadbalancers_find_by_network_load_balancer_id',
            return_type: 'NetworkLoadBalancer',
            result: network_loadbalancer,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should call NetworkLoadBalancersApi.datacenters_networkloadbalancers_forwardingrules_patch_with_http_info 2' do
      network_loadbalancer_rule = network_loadbalancer_rule_mock(
        targets: [
          network_loadbalancer_rule_target_mock(
            port: 123, ip: '127.0.0.3', check_interval: 2345, maintenance: true, check: true, weight: 13,
          ),
          network_loadbalancer_rule_target_mock(
            port: 1234, ip: '127.0.0.6', check_interval: 1231, maintenance: true, check: false, weight: 456,
          ),
          network_loadbalancer_rule_target_mock(
            port: 112, ip: '127.0.0.8', check_interval: 2525, maintenance: true, check: true, weight: 425,
          ),
          network_loadbalancer_rule_target_mock(
            port: 123, ip: '127.0.0.8', check_interval: 36346, maintenance: false, check: false, weight: 4,
          ),
          network_loadbalancer_rule_target_mock(
            port: 164, ip: '127.0.0.3', check_interval: 243, maintenance: true, check: false, weight: 123,
          ),
        ]
      )
      network_loadbalancer = network_loadbalancer_mock(
        rules: Ionoscloud::NetworkLoadBalancers.new(
          id: 'network_loadbalancers',
          type: 'collection',
          items: [network_loadbalancer_rule, network_loadbalancer_rule_mock],
        )
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

      fw_rules = network_loadbalancer.entities.forwardingrules.items.map do |rule|
        {
          id: rule.id,
          name: rule.properties.name,
          algorithm: rule.properties.algorithm,
          protocol: rule.properties.protocol,
          listener_ip: rule.properties.listener_ip,
          listener_port: rule.properties.listener_port,
          health_check: rule.properties.health_check.nil? ? nil : rule.properties.health_check.to_hash,
          targets: rule.properties.targets.map { |target| target.to_hash },
        }
      end

      fw_rules[0][:targets] = remaining_targets.map { |target| target.to_hash }

      expect(subject).to receive(:puts).with("ID: #{network_loadbalancer.id}")
      expect(subject).to receive(:puts).with("Name: #{network_loadbalancer.properties.name}")
      expect(subject).to receive(:puts).with("Listener LAN: #{network_loadbalancer.properties.listener_lan}")
      expect(subject).to receive(:puts).with("IPS: #{network_loadbalancer.properties.ips}")
      expect(subject).to receive(:puts).with("Target LAN: #{network_loadbalancer.properties.target_lan}")
      expect(subject).to receive(:puts).with("Private IPS: #{network_loadbalancer.properties.lb_private_ips}")
      expect(subject).to receive(:puts).with("Forwarding Rules: #{fw_rules}")
      expect(subject).to receive(:puts).with("Flowlogs: #{network_loadbalancer.entities.flowlogs.items.map { |flowlog| flowlog.id }}")

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
            path: "/datacenters/#{subject_config[:datacenter_id]}/networkloadbalancers/#{subject_config[:network_loadbalancer_id]}",
            operation: :'NetworkLoadBalancersApi.datacenters_networkloadbalancers_find_by_network_load_balancer_id',
            return_type: 'NetworkLoadBalancer',
            result: network_loadbalancer,
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
            port: 123, ip: '127.0.0.3', check_interval: 2345, maintenance: true, check: true, weight: 13,
          ),
        ]
      )
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        network_loadbalancer_id: network_loadbalancer.id,
        forwarding_rule_id: network_loadbalancer_rule.id,
        ip: '127.0.0.4',
        port: 123,
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

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
