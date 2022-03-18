require 'spec_helper'
require 'ionoscloud_applicationloadbalancer_rule_update'

Chef::Knife::IonoscloudApplicationloadbalancerRuleUpdate.load_deps

describe Chef::Knife::IonoscloudApplicationloadbalancerRuleUpdate do
  before :each do
    subject { Chef::Knife::IonoscloudApplicationloadbalancerRuleUpdate.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call ApplicationLoadBalancersApi.datacenters_applicationloadbalancers_patch' do
      application_loadbalancer_rule = application_loadbalancer_rule_mock
      application_loadbalancer = application_loadbalancer_mock(
        rules: Ionoscloud::ApplicationLoadBalancerForwardingRules.new(
          id: 'application_loadbalancers_forwardingrules',
          type: 'collection',
          items: [application_loadbalancer_rule],
        ),
      )
      application_loadbalancer_rule_httprule = application_loadbalancer_rule_httprule_mock(
        name: 'test_name',
        type: 'STATIC',
        content_type: 'new_content_type',
        conditions: [],
      )

      existing_httprule_new_name = application_loadbalancer_rule.properties.http_rules.first.name + '_edited'
      existing_httprule_new_location = application_loadbalancer_rule.properties.http_rules.first.location + '_edited'
      existing_httprule_new_status_code = 503
      existing_httprule_new_response_message = application_loadbalancer_rule.properties.http_rules.first.response_message + '_edited'
      existing_httprule_new_content_type = application_loadbalancer_rule.properties.http_rules.first.content_type + '_edited'

      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        application_loadbalancer_id: application_loadbalancer.id,
        forwarding_rule_id: application_loadbalancer_rule.id,
        name: application_loadbalancer_rule.properties.name + '_edit',
        listener_ip: '127.1.1.1',
        listener_port: 30,
        client_timeout: 3000,
        http_rules: application_loadbalancer_rule.properties.http_rules.map do |el|
          hash = el.to_hash
          hash[:conditions].map! do |condition|
            condition.collect { |k, v| [k.to_s, v] }.to_h
          end
          {
            'name' => existing_httprule_new_name,
            'type' => hash[:type],
            'target_group' => hash[:targetGroup],
            'drop_query' => hash[:dropQuery],
            'location' => existing_httprule_new_location,
            'status_code' => existing_httprule_new_status_code,
            'response_message' => existing_httprule_new_response_message,
            'content_type' => existing_httprule_new_content_type,
            'conditions' => hash[:conditions],
          }
        end + [application_loadbalancer_rule_httprule].map do |el|
          hash = el.to_hash
          hash[:conditions].map! do |condition|
            condition.collect { |k, v| [k.to_s, v] }.to_h
          end
          {
            'name' => hash[:name],
            'type' => hash[:type],
            'target_group' => hash[:targetGroup],
            'drop_query' => hash[:dropQuery],
            'location' => hash[:location],
            'status_code' => hash[:statusCode],
            'response_message' => hash[:responseMessage],
            'content_type' => hash[:contentType],
            'conditions' => hash[:conditions],
          }
        end,
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }


      expect(subject).to receive(:puts).with("ID: #{application_loadbalancer.id}")
      expect(subject).to receive(:puts).with("Name: #{application_loadbalancer.properties.name}")
      expect(subject).to receive(:puts).with("Listener LAN: #{application_loadbalancer.properties.listener_lan}")
      expect(subject).to receive(:puts).with("IPS: #{application_loadbalancer.properties.ips}")
      expect(subject).to receive(:puts).with("Target LAN: #{application_loadbalancer.properties.target_lan}")
      expect(subject).to receive(:puts).with("Lb Private IPS: #{application_loadbalancer.properties.lb_private_ips}")

      application_loadbalancer.entities.forwardingrules.items.first.properties.name = subject_config[:name]
      application_loadbalancer.entities.forwardingrules.items.first.properties.listener_ip = subject_config[:listener_ip]
      application_loadbalancer.entities.forwardingrules.items.first.properties.listener_port = subject_config[:listener_port]
      application_loadbalancer.entities.forwardingrules.items.first.properties.client_timeout = subject_config[:client_timeout]

      application_loadbalancer.entities.forwardingrules.items.first.properties.http_rules.first.name = existing_httprule_new_name
      application_loadbalancer.entities.forwardingrules.items.first.properties.http_rules.first.location = existing_httprule_new_location
      application_loadbalancer.entities.forwardingrules.items.first.properties.http_rules.first.status_code = existing_httprule_new_status_code
      application_loadbalancer.entities.forwardingrules.items.first.properties.http_rules.first.response_message = existing_httprule_new_response_message
      application_loadbalancer.entities.forwardingrules.items.first.properties.http_rules.first.content_type = existing_httprule_new_content_type

      application_loadbalancer.entities.forwardingrules.items.first.properties.http_rules << application_loadbalancer_rule_httprule

      expect(subject).to receive(:puts).with("Rules: #{
        application_loadbalancer.entities.forwardingrules.items.map do |rule|
        {
          id: rule.id,
          name: subject_config[:name],
          protocol: application_loadbalancer_rule.properties.protocol,
          listener_ip: subject_config[:listener_ip],
          listener_port: subject_config[:listener_port],
          client_timeout: subject_config[:client_timeout],
          server_certificates: application_loadbalancer_rule.properties.server_certificates,
          http_rules: rule.properties.http_rules.map do |http_rule|
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
              end,
            }
          end,
        }
      end}")

      http_rules_body = application_loadbalancer.entities.forwardingrules.items.first.properties.http_rules.map do |el|
        hash = el.to_hash
        hash[:conditions].map! do |condition|
          condition.collect { |k, v| [k.to_s, v] }.to_h
        end
        {
          name: hash[:name],
          type: hash[:type],
          targetGroup: hash[:targetGroup],
          dropQuery: hash[:dropQuery],
          location: hash[:location],
          statusCode: hash[:statusCode],
          responseMessage: hash[:responseMessage],
          contentType: hash[:contentType],
          conditions: hash[:conditions].map do |condition|
            condition
            {
              type: condition['type'],
              condition: condition['condition'],
              negate: condition['negate'],
              key: condition['key'],
              value: condition['value'],
            }
          end,
        }
      end

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'PATCH',
            path: "/datacenters/#{subject_config[:datacenter_id]}/applicationloadbalancers/"\
            "#{subject_config[:application_loadbalancer_id]}/forwardingrules/#{subject_config[:forwarding_rule_id]}",
            operation: :'ApplicationLoadBalancersApi.datacenters_applicationloadbalancers_forwardingrules_patch',
            return_type: 'ApplicationLoadBalancerForwardingRule',
            body: {
              name: subject_config[:name],
              listenerIp: subject_config[:listener_ip],
              listenerPort: subject_config[:listener_port],
              clientTimeout: subject_config[:client_timeout],
              httpRules: http_rules_body,
            },
            result: application_loadbalancer.entities.forwardingrules.items.first,
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
