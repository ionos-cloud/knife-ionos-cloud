require 'spec_helper'
require 'ionoscloud_applicationloadbalancer_rule_httprule_remove'

Chef::Knife::IonoscloudApplicationloadbalancerRuleHttpruleRemove.load_deps

describe Chef::Knife::IonoscloudApplicationloadbalancerRuleHttpruleRemove do
  before :each do
    subject { Chef::Knife::IonoscloudApplicationloadbalancerRuleHttpruleRemove.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call ApplicationLoadBalancersApi.datacenters_applicationloadbalancers_forwardingrules_patch_with_http_info '\
  'when the ID is valid' do
      application_loadbalancer = application_loadbalancer_mock
      application_loadbalancer_rule = application_loadbalancer_rule_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        application_loadbalancer_id: application_loadbalancer.id,
        forwarding_rule_id: application_loadbalancer.entities.forwardingrules.items.first.id,
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [application_loadbalancer.entities.forwardingrules.items.first.properties.http_rules.first.name, 'invalid_name']

      forwarding_rule = application_loadbalancer.entities.forwardingrules.items.first

      expect(subject).to receive(:puts).with("ID: #{application_loadbalancer.id}")
      expect(subject).to receive(:puts).with("Name: #{application_loadbalancer.properties.name}")
      expect(subject).to receive(:puts).with("Listener LAN: #{application_loadbalancer.properties.listener_lan}")
      expect(subject).to receive(:puts).with("IPS: #{application_loadbalancer.properties.ips}")
      expect(subject).to receive(:puts).with("Target LAN: #{application_loadbalancer.properties.target_lan}")
      expect(subject).to receive(:puts).with("Lb Private IPS: #{application_loadbalancer.properties.lb_private_ips}")
      expect(subject).to receive(:puts).with("Rules: #{[{
        id: forwarding_rule.id,
        name: forwarding_rule.properties.name,
        protocol: forwarding_rule.properties.protocol,
        listener_ip: forwarding_rule.properties.listener_ip,
        listener_port: forwarding_rule.properties.listener_port,
        health_check: {
          client_timeout: forwarding_rule.properties.health_check.client_timeout,
        },
        server_certificates: forwarding_rule.properties.server_certificates,
        http_rules: []
      }, subject.get_application_loadbalancer_extended_properties(application_loadbalancer)[1]]}")
      expect(subject).to receive(:print).with("Removing the Http Rules #{[subject.name_args.first]} from the Application Loadbalancer Forwarding Rule...")

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/applicationloadbalancers/"\
            "#{subject_config[:application_loadbalancer_id]}/forwardingrules/#{subject_config[:forwarding_rule_id]}",
            operation: :'ApplicationLoadBalancersApi.datacenters_applicationloadbalancers_forwardingrules_find_by_forwarding_rule_id',
            return_type: 'ApplicationLoadBalancerForwardingRule',
            result: application_loadbalancer.entities.forwardingrules.items.first,
          },
          {
            method: 'PATCH',
            path: "/datacenters/#{subject_config[:datacenter_id]}/applicationloadbalancers/"\
            "#{subject_config[:application_loadbalancer_id]}/forwardingrules/#{subject_config[:forwarding_rule_id]}",
            operation: :'ApplicationLoadBalancersApi.datacenters_applicationloadbalancers_forwardingrules_patch',
            body: {
              httpRules: [],
            },
            return_type: 'ApplicationLoadBalancerForwardingRule',
          },
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/applicationloadbalancers/#{application_loadbalancer.id}",
            operation: :'ApplicationLoadBalancersApi.datacenters_applicationloadbalancers_find_by_application_load_balancer_id',
            return_type: 'ApplicationLoadBalancer',
            result: application_loadbalancer,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not call ApplicationLoadBalancersApi.datacenters_applicationloadbalancers_forwardingrules_patch_with_http_info '\
  'when the ID is not valid' do
      application_loadbalancer = application_loadbalancer_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        application_loadbalancer_id: application_loadbalancer.id,
        forwarding_rule_id: application_loadbalancer.entities.forwardingrules.items.first.id,
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = ['invalid_id', 'invalid_id2']

      expect(subject).to receive(:puts).with("ID: #{application_loadbalancer.id}")
      expect(subject).to receive(:puts).with("Name: #{application_loadbalancer.properties.name}")
      expect(subject).to receive(:puts).with("Listener LAN: #{application_loadbalancer.properties.listener_lan}")
      expect(subject).to receive(:puts).with("IPS: #{application_loadbalancer.properties.ips}")
      expect(subject).to receive(:puts).with("Target LAN: #{application_loadbalancer.properties.target_lan}")
      expect(subject).to receive(:puts).with("Lb Private IPS: #{application_loadbalancer.properties.lb_private_ips}")
      expect(subject).to receive(:puts).with("Rules: #{subject.get_application_loadbalancer_extended_properties(application_loadbalancer)}")

      expect(subject.ui).to receive(:warn).with('No name of an existing Http Rule was given.')

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/applicationloadbalancers/"\
            "#{subject_config[:application_loadbalancer_id]}/forwardingrules/#{subject_config[:forwarding_rule_id]}",
            operation: :'ApplicationLoadBalancersApi.datacenters_applicationloadbalancers_forwardingrules_find_by_forwarding_rule_id',
            return_type: 'ApplicationLoadBalancerForwardingRule',
            result: application_loadbalancer.entities.forwardingrules.items.first,
          },
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/applicationloadbalancers/#{application_loadbalancer.id}",
            operation: :'ApplicationLoadBalancersApi.datacenters_applicationloadbalancers_find_by_application_load_balancer_id',
            return_type: 'ApplicationLoadBalancer',
            result: application_loadbalancer,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not call ApplicationLoadBalancersApi.datacenters_applicationloadbalancers_forwardingrules_patch_with_http_info '\
  'when the rules has to existing Http Rule' do
      application_loadbalancer = application_loadbalancer_mock
      application_loadbalancer.entities.forwardingrules.items.first.properties.http_rules = nil
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        application_loadbalancer_id: application_loadbalancer.id,
        forwarding_rule_id: application_loadbalancer.entities.forwardingrules.items.first.id,
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = ['invalid_id', 'invalid_id2']

      expect(subject).to receive(:puts).with("ID: #{application_loadbalancer.id}")
      expect(subject).to receive(:puts).with("Name: #{application_loadbalancer.properties.name}")
      expect(subject).to receive(:puts).with("Listener LAN: #{application_loadbalancer.properties.listener_lan}")
      expect(subject).to receive(:puts).with("IPS: #{application_loadbalancer.properties.ips}")
      expect(subject).to receive(:puts).with("Target LAN: #{application_loadbalancer.properties.target_lan}")
      expect(subject).to receive(:puts).with("Lb Private IPS: #{application_loadbalancer.properties.lb_private_ips}")
      expect(subject).to receive(:puts).with("Rules: #{subject.get_application_loadbalancer_extended_properties(application_loadbalancer)}")

      expect(subject.ui).to receive(:warn).with("The Forwarding Rule #{subject_config[:forwarding_rule_id]} has no Http Rules.")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/applicationloadbalancers/"\
            "#{subject_config[:application_loadbalancer_id]}/forwardingrules/#{subject_config[:forwarding_rule_id]}",
            operation: :'ApplicationLoadBalancersApi.datacenters_applicationloadbalancers_forwardingrules_find_by_forwarding_rule_id',
            return_type: 'ApplicationLoadBalancerForwardingRule',
            result: application_loadbalancer.entities.forwardingrules.items.first,
          },
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/applicationloadbalancers/#{application_loadbalancer.id}",
            operation: :'ApplicationLoadBalancersApi.datacenters_applicationloadbalancers_find_by_application_load_balancer_id',
            return_type: 'ApplicationLoadBalancer',
            result: application_loadbalancer,
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
