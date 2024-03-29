require 'spec_helper'
require 'ionoscloud_networkloadbalancer_rule_list'

Chef::Knife::IonoscloudNetworkloadbalancerRuleList.load_deps

describe Chef::Knife::IonoscloudNetworkloadbalancerRuleList do
  before :each do
    subject { Chef::Knife::IonoscloudNetworkloadbalancerRuleList.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call NetworkLoadBalancersApi.datacenters_networkloadbalancers_forwardingrules_get' do
      network_loadbalancer_rules = network_loadbalancer_rules_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        network_loadbalancer_id: 'network_loadbalancer_id',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      network_loadbalancer_list = [
        subject.ui.color('ID', :bold),
        subject.ui.color('Name', :bold),
        subject.ui.color('Algorithm', :bold),
        subject.ui.color('Protocol', :bold),
        subject.ui.color('Listener IP', :bold),
        subject.ui.color('Listener Port', :bold),
        subject.ui.color('Targets', :bold),
        subject.ui.color('Health Check', :bold),
        network_loadbalancer_rules.items.first.id,
        network_loadbalancer_rules.items.first.properties.name,
        network_loadbalancer_rules.items.first.properties.algorithm,
        network_loadbalancer_rules.items.first.properties.protocol,
        network_loadbalancer_rules.items.first.properties.listener_ip,
        network_loadbalancer_rules.items.first.properties.listener_port,
        network_loadbalancer_rules.items.first.properties.targets.length,
        network_loadbalancer_rules.items.first.properties.health_check,
        network_loadbalancer_rules.items[1].id,
        network_loadbalancer_rules.items[1].properties.name,
        network_loadbalancer_rules.items[1].properties.algorithm,
        network_loadbalancer_rules.items[1].properties.protocol,
        network_loadbalancer_rules.items[1].properties.listener_ip,
        network_loadbalancer_rules.items[1].properties.listener_port,
        network_loadbalancer_rules.items[1].properties.targets.length,
        network_loadbalancer_rules.items[1].properties.health_check,
      ]

      expect(subject.ui).to receive(:list).with(network_loadbalancer_list, :uneven_columns_across, 8)

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/networkloadbalancers/#{subject_config[:network_loadbalancer_id]}/forwardingrules",
            operation: :'NetworkLoadBalancersApi.datacenters_networkloadbalancers_forwardingrules_get',
            return_type: 'NetworkLoadBalancerForwardingRules',
            result: network_loadbalancer_rules,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not make any call if any required option is missing' do
      required_options = subject.instance_variable_get(:@required_options)

      if required_options.length > 0
        arrays_without_one_element(required_options).each do |test_case|
          subject.config[:ionoscloud_token] = 'token'
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
end
