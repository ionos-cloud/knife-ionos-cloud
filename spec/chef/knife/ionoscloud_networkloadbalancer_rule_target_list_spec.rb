require 'spec_helper'
require 'ionoscloud_networkloadbalancer_rule_target_list'

Chef::Knife::IonoscloudNetworkloadbalancerRuleTargetList.load_deps

describe Chef::Knife::IonoscloudNetworkloadbalancerRuleTargetList do
  before :each do
    subject { Chef::Knife::IonoscloudNetworkloadbalancerRuleTargetList.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call NetworkLoadBalancersApi.datacenters_networkloadbalancers_forwardingrules_get' do
      network_loadbalancer_rule = network_loadbalancer_rule_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        network_loadbalancer_id: 'network_loadbalancer_id',
        forwarding_rule_id: network_loadbalancer_rule.id,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      network_loadbalancer_list = [
        subject.ui.color('IP', :bold),
        subject.ui.color('Port', :bold),
        subject.ui.color('Weight', :bold),
        subject.ui.color('Check', :bold),
        subject.ui.color('Check interval', :bold),
        subject.ui.color('Maintenance', :bold),
        network_loadbalancer_rule.properties.targets.first.ip,
        network_loadbalancer_rule.properties.targets.first.port,
        network_loadbalancer_rule.properties.targets.first.weight,
        network_loadbalancer_rule.properties.targets.first.health_check.check,
        network_loadbalancer_rule.properties.targets.first.health_check.check_interval,
        network_loadbalancer_rule.properties.targets.first.health_check.maintenance,
        network_loadbalancer_rule.properties.targets[1].ip,
        network_loadbalancer_rule.properties.targets[1].port,
        network_loadbalancer_rule.properties.targets[1].weight,
        network_loadbalancer_rule.properties.targets[1].health_check.check,
        network_loadbalancer_rule.properties.targets[1].health_check.check_interval,
        network_loadbalancer_rule.properties.targets[1].health_check.maintenance,
      ]

      expect(subject.ui).to receive(:list).with(network_loadbalancer_list, :uneven_columns_across, 6)

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
