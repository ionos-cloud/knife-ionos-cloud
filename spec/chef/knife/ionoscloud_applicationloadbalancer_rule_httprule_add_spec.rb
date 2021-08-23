require 'spec_helper'
require 'ionoscloud_applicationloadbalancer_rule_httprule_add'

Chef::Knife::IonoscloudApplicationloadbalancerRuleHttpruleAdd.load_deps

describe Chef::Knife::IonoscloudApplicationloadbalancerRuleHttpruleAdd do
  before :each do
    subject { Chef::Knife::IonoscloudApplicationloadbalancerRuleHttpruleAdd.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call ApplicationLoadBalancersApi.datacenters_applicationloadbalancers_forwardingrules_patch_with_http_info '\
    'and add a new Http Rule' do
      application_loadbalancer = application_loadbalancer_mock
      application_loadbalancer_rule_httprule = application_loadbalancer_rule_httprule_mock(name: 'test')
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        application_loadbalancer_id: application_loadbalancer.id,
        forwarding_rule_id: application_loadbalancer.entities.forwardingrules.items.first.id,
        name: application_loadbalancer_rule_httprule.name,
        type: application_loadbalancer_rule_httprule.type,
        target_group: application_loadbalancer_rule_httprule.target_group,
        drop_query: application_loadbalancer_rule_httprule.drop_query,
        location: application_loadbalancer_rule_httprule.location,
        status_code: application_loadbalancer_rule_httprule.status_code,
        response_message: application_loadbalancer_rule_httprule.response_message,
        content_type: application_loadbalancer_rule_httprule.content_type,
        conditions: application_loadbalancer_rule_httprule.conditions.map { |el| el.to_hash },
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      forwarding_rule = application_loadbalancer.entities.forwardingrules.items.first

      expected_rule_print = {
        name: application_loadbalancer_rule_httprule.name,
        type: application_loadbalancer_rule_httprule.type,
        target_group: application_loadbalancer_rule_httprule.target_group,
        drop_query: application_loadbalancer_rule_httprule.drop_query,
        location: application_loadbalancer_rule_httprule.location,
        status_code: application_loadbalancer_rule_httprule.status_code,
        response_message: application_loadbalancer_rule_httprule.response_message,
        content_type: application_loadbalancer_rule_httprule.content_type,
        conditions: application_loadbalancer_rule_httprule.conditions.map { |el| el.to_hash },
      }
      expect(subject).to receive(:puts).with("ID: #{application_loadbalancer.id}")
      expect(subject).to receive(:puts).with("Name: #{application_loadbalancer.properties.name}")
      expect(subject).to receive(:puts).with("Listener LAN: #{application_loadbalancer.properties.listener_lan}")
      expect(subject).to receive(:puts).with("IPS: #{application_loadbalancer.properties.ips}")
      expect(subject).to receive(:puts).with("Target LAN: #{application_loadbalancer.properties.target_lan}")
      expect(subject).to receive(:puts).with("Lb Private IPS: #{application_loadbalancer.properties.lb_private_ips}")
      expect(subject).to receive(:puts).with("Rules: #{[{
        id:forwarding_rule.id,
        name: forwarding_rule.properties.name,
        protocol: forwarding_rule.properties.protocol,
        listener_ip: forwarding_rule.properties.listener_ip,
        listener_port: forwarding_rule.properties.listener_port,
        health_check: {
          client_timeout: forwarding_rule.properties.health_check.client_timeout,
        },
        server_certificates: forwarding_rule.properties.server_certificates,
        http_rules: forwarding_rule.properties.http_rules.map do |http_rule|
          {
            name: http_rule.name,
            type: http_rule.type,
            target_group: http_rule.target_group,
            drop_query: http_rule.drop_query,
            location: http_rule.location,
            status_code: http_rule.status_code,
            response_message: http_rule.response_message,
            content_type: http_rule.content_type,
            conditions: http_rule.conditions.nil? ? [] : http_rule.conditions.map do |condition|
              {
                type: condition.type,
                condition: condition.condition,
                negate: condition.negate,
                key: condition.key,
                value: condition.value,
              }
            end
          }
        end + [expected_rule_print]
      }, subject.get_application_loadbalancer_extended_properties(application_loadbalancer)[1]]}")

      expected_added_httprule_body = application_loadbalancer_rule_httprule.to_hash

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
              httpRules: application_loadbalancer.entities.forwardingrules.items.first.properties.http_rules.map(&:to_hash) + [expected_added_httprule_body],
            },
            return_type: 'ApplicationLoadBalancerForwardingRule',
          },
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/applicationloadbalancers/#{subject_config[:application_loadbalancer_id]}",
            operation: :'ApplicationLoadBalancersApi.datacenters_applicationloadbalancers_find_by_application_load_balancer_id',
            return_type: 'ApplicationLoadBalancer',
            result: application_loadbalancer,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should call ApplicationLoadBalancersApi.datacenters_applicationloadbalancers_forwardingrules_patch_with_http_info '\
    'and update an existing Http Rule' do
      application_loadbalancer = application_loadbalancer_mock
      application_loadbalancer_rule_httprule = application_loadbalancer_rule_httprule_mock(location: 'www.not-ionos.com', message: 'new_message')
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        application_loadbalancer_id: application_loadbalancer.id,
        forwarding_rule_id: application_loadbalancer.entities.forwardingrules.items.first.id,
        name: application_loadbalancer_rule_httprule.name,
        type: application_loadbalancer_rule_httprule.type,
        location: application_loadbalancer_rule_httprule.location,
        response_message: application_loadbalancer_rule_httprule.response_message,
        conditions: "[" + JSON[application_loadbalancer_rule_httprule.conditions.first.to_hash] + 
        ',' + JSON[application_loadbalancer_rule_httprule.conditions.first.to_hash] + "]",
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      forwarding_rule = application_loadbalancer.entities.forwardingrules.items.first

      expected_rule_print = {
        name: application_loadbalancer_rule_httprule.name,
        type: application_loadbalancer_rule_httprule.type,
        target_group: application_loadbalancer_rule_httprule.target_group,
        drop_query: application_loadbalancer_rule_httprule.drop_query,
        location: application_loadbalancer_rule_httprule.location,
        status_code: application_loadbalancer_rule_httprule.status_code,
        response_message: application_loadbalancer_rule_httprule.response_message,
        content_type: application_loadbalancer_rule_httprule.content_type,
        conditions: [],
      }
      expect(subject).to receive(:puts).with("ID: #{application_loadbalancer.id}")
      expect(subject).to receive(:puts).with("Name: #{application_loadbalancer.properties.name}")
      expect(subject).to receive(:puts).with("Listener LAN: #{application_loadbalancer.properties.listener_lan}")
      expect(subject).to receive(:puts).with("IPS: #{application_loadbalancer.properties.ips}")
      expect(subject).to receive(:puts).with("Target LAN: #{application_loadbalancer.properties.target_lan}")
      expect(subject).to receive(:puts).with("Lb Private IPS: #{application_loadbalancer.properties.lb_private_ips}")
      expect(subject).to receive(:puts).with("Rules: #{[{
        id:forwarding_rule.id,
        name: forwarding_rule.properties.name,
        protocol: forwarding_rule.properties.protocol,
        listener_ip: forwarding_rule.properties.listener_ip,
        listener_port: forwarding_rule.properties.listener_port,
        health_check: {
          client_timeout: forwarding_rule.properties.health_check.client_timeout,
        },
        server_certificates: forwarding_rule.properties.server_certificates,
        http_rules: [{
          name: application_loadbalancer_rule_httprule.name,
          type: application_loadbalancer_rule_httprule.type,
          target_group: application_loadbalancer.entities.forwardingrules.items.first.properties.http_rules.first.target_group,
          drop_query: application_loadbalancer_rule_httprule.drop_query,
          location: application_loadbalancer_rule_httprule.location,
          status_code: application_loadbalancer_rule_httprule.status_code,
          response_message: application_loadbalancer_rule_httprule.response_message,
          content_type: application_loadbalancer_rule_httprule.content_type,
          conditions: [
            application_loadbalancer_rule_httprule.conditions.first.to_hash,
            application_loadbalancer_rule_httprule.conditions.first.to_hash,
          ]
        }]
      }, subject.get_application_loadbalancer_extended_properties(application_loadbalancer)[1]]}")

      expected_added_httprule_body = application_loadbalancer_rule_httprule.to_hash
      expected_added_httprule_body[:targetGroup] = application_loadbalancer.entities.forwardingrules.items.first.properties.http_rules.first.target_group
      expected_added_httprule_body[:conditions] << application_loadbalancer_rule_httprule.conditions.first.to_hash

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
              httpRules: [expected_added_httprule_body],
            },
            return_type: 'ApplicationLoadBalancerForwardingRule',
          },
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/applicationloadbalancers/#{subject_config[:application_loadbalancer_id]}",
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
