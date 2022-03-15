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
      network_loadbalancer_rule = network_loadbalancer.entities.forwardingrules.items[0]
      network_loadbalancer_rule_target = network_loadbalancer_rule_target_mock(
        port: 123, ip: '127.0.0.3', check_interval: 2345, maintenance: true, check: false, weight: 13,
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

      fw_rules = network_loadbalancer.entities.forwardingrules.items.map do |rule|
        {
          id: rule.id,
          name: rule.properties.name,
          algorithm: rule.properties.algorithm,
          protocol: rule.properties.protocol,
          listener_ip: rule.properties.listener_ip,
          listener_port: rule.properties.listener_port,
          health_check: rule.properties.health_check.nil? ? nil : rule.properties.health_check.to_hash,
          targets: (network_loadbalancer_rule.properties.targets).map { |target| target.to_hash },
        }
      end

      fw_rules[0][:targets] += [network_loadbalancer_rule_target.to_hash]

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
            body: { targets: (network_loadbalancer_rule.properties.targets + [network_loadbalancer_rule_target]).map { |target| target.to_hash } },
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
