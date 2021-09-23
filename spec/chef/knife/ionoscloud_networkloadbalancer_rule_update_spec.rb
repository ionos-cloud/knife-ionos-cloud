require 'spec_helper'
require 'ionoscloud_networkloadbalancer_rule_update'

Chef::Knife::IonoscloudNetworkloadbalancerRuleUpdate.load_deps

describe Chef::Knife::IonoscloudNetworkloadbalancerRuleUpdate do
  before :each do
    subject { Chef::Knife::IonoscloudNetworkloadbalancerRuleUpdate.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call NetworkInterfacesApi.datacenters_networkloadbalancers_forwardingrules_patch' do
      network_loadbalancer = network_loadbalancer_mock
      network_loadbalancer_rule = network_loadbalancer.entities.forwardingrules.items[0]
      
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        network_loadbalancer_id: network_loadbalancer.id,
        forwarding_rule_id: network_loadbalancer_rule.id,
        name: network_loadbalancer_rule.properties.name + '_edited',
        algorithm: 'LEAST_CONNECTION',
        protocol: 'HTTP',
        listener_ip: '1.1.1.1',
        listener_port: network_loadbalancer_rule.properties.listener_port + 10,
        client_timeout: network_loadbalancer_rule.properties.health_check.client_timeout + 100,
        connect_timeout: network_loadbalancer_rule.properties.health_check.connect_timeout + 100,
        target_timeout: network_loadbalancer_rule.properties.health_check.target_timeout + 100,
        retries: network_loadbalancer_rule.properties.health_check.retries + 1,
        targets: [
          {
            'ip' => '1.1.1.1',
            'port' => 11,
            'weight' => 15,
            'health_check' => {
              'check' => true,
              'check_interval' => 1200,
              'maintenance' => false,
            },
          },
          {
            'ip' => '1.1.1.1',
            'port' => 14,
            'weight' => 18,
            'health_check' => {
              'check' => false,
              'check_interval' => 1500,
              'maintenance' => true,
            },
          },
        ],
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      parsed_targets = subject_config[:targets].map do
        |target|
        Ionoscloud::NetworkLoadBalancerForwardingRuleTarget.new(
          ip: target['ip'],
          port: target['port'],
          weight: target['weight'],
          health_check: Ionoscloud::NetworkLoadBalancerForwardingRuleTargetHealthCheck.new(
            check: target['health_check']['check'],
            check_interval: target['health_check']['check_interval'],
            maintenance: target['health_check']['maintenance'],
          ),
        )
      end

      network_loadbalancer.entities.forwardingrules.items[0].properties.name = subject_config[:name]
      network_loadbalancer.entities.forwardingrules.items[0].properties.algorithm = subject_config[:algorithm]
      network_loadbalancer.entities.forwardingrules.items[0].properties.protocol = subject_config[:protocol]
      network_loadbalancer.entities.forwardingrules.items[0].properties.listener_ip = subject_config[:listener_ip]
      network_loadbalancer.entities.forwardingrules.items[0].properties.listener_port = subject_config[:algorithm]
      network_loadbalancer.entities.forwardingrules.items[0].properties.health_check.client_timeout = subject_config[:client_timeout]
      network_loadbalancer.entities.forwardingrules.items[0].properties.health_check.connect_timeout = subject_config[:connect_timeout]
      network_loadbalancer.entities.forwardingrules.items[0].properties.health_check.target_timeout = subject_config[:target_timeout]
      network_loadbalancer.entities.forwardingrules.items[0].properties.health_check.retries = subject_config[:retries]
      network_loadbalancer.entities.forwardingrules.items[0].properties.targets = parsed_targets

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
            method: 'PATCH',
            path: "/datacenters/#{subject_config[:datacenter_id]}/networkloadbalancers/#{subject_config[:network_loadbalancer_id]}/"\
            "forwardingrules/#{subject_config[:forwarding_rule_id]}",
            operation: :'NetworkLoadBalancersApi.datacenters_networkloadbalancers_forwardingrules_patch',
            return_type: 'NetworkLoadBalancerForwardingRule',
            body: {
              name: subject_config[:name],
              algorithm: subject_config[:algorithm],
              protocol: subject_config[:protocol],
              listenerIp: subject_config[:listener_ip],
              listenerPort: subject_config[:listener_port],
              healthCheck: {
                clientTimeout: subject_config[:client_timeout],
                connectTimeout: subject_config[:connect_timeout],
                targetTimeout: subject_config[:target_timeout],
                retries: subject_config[:retries],
              },
              targets: parsed_targets.map(&:to_hash),
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
