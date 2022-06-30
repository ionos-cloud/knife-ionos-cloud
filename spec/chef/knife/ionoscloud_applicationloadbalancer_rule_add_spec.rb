require 'spec_helper'
require 'ionoscloud_applicationloadbalancer_rule_add'

Chef::Knife::IonoscloudApplicationloadbalancerRuleAdd.load_deps

describe Chef::Knife::IonoscloudApplicationloadbalancerRuleAdd do
  before :each do
    subject { Chef::Knife::IonoscloudApplicationloadbalancerRuleAdd.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call ApplicationLoadBalancersApi.datacenters_applicationloadbalancers_forwardingrules_post_with_http_info' do
      application_loadbalancer = application_loadbalancer_mock
      application_loadbalancer_rule = application_loadbalancer_rule_mock

      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        application_loadbalancer_id: application_loadbalancer.id,
        name: application_loadbalancer_rule.properties.name,
        protocol: application_loadbalancer_rule.properties.protocol,
        listener_ip: application_loadbalancer_rule.properties.listener_ip,
        listener_port: application_loadbalancer_rule.properties.listener_port,
        client_timeout: application_loadbalancer_rule.properties.client_timeout,
        server_certificates: application_loadbalancer_rule.properties.server_certificates.join(','),
        http_rules: application_loadbalancer_rule.properties.http_rules.map do |el|
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
      expect(subject).to receive(:puts).with("Rules: #{
        (application_loadbalancer.entities.forwardingrules.items + [application_loadbalancer_rule]).map do |rule|
        {
          id: rule.id,
          name: application_loadbalancer_rule.properties.name,
          protocol: application_loadbalancer_rule.properties.protocol,
          listener_ip: application_loadbalancer_rule.properties.listener_ip,
          listener_port: application_loadbalancer_rule.properties.listener_port,
          client_timeout: application_loadbalancer_rule.properties.client_timeout,
          server_certificates: application_loadbalancer_rule.properties.server_certificates,
          http_rules: rule.properties.http_rules.nil? ? [] : rule.properties.http_rules.map do |http_rule|
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

      application_loadbalancer.entities.forwardingrules.items << application_loadbalancer_rule
      expected_properties = application_loadbalancer_rule.properties.to_hash

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'POST',
            path: "/datacenters/#{subject_config[:datacenter_id]}/applicationloadbalancers/#{subject_config[:application_loadbalancer_id]}/forwardingrules",
            operation: :'ApplicationLoadBalancersApi.datacenters_applicationloadbalancers_forwardingrules_post',
            body: { properties: expected_properties },
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
