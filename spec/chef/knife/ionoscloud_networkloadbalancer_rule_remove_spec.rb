require 'spec_helper'
require 'ionoscloud_networkloadbalancer_rule_remove'

Chef::Knife::IonoscloudNetworkloadbalancerRuleRemove.load_deps

describe Chef::Knife::IonoscloudNetworkloadbalancerRuleRemove do
  before :each do
    subject { Chef::Knife::IonoscloudNetworkloadbalancerRuleRemove.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call NetworkLoadBalancersApi.datacenters_networkloadbalancers_forwardingrules_delete when the ID is valid' do
      network_loadbalancer = network_loadbalancer_mock
      rule = network_loadbalancer.entities.forwardingrules.items[0]
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        network_loadbalancer_id: network_loadbalancer.id,
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [rule.id]

      expect(subject).to receive(:puts).with("ID: #{network_loadbalancer.id}")
      expect(subject).to receive(:puts).with("Name: #{network_loadbalancer.properties.name}")
      expect(subject).to receive(:puts).with("Listener LAN: #{network_loadbalancer.properties.listener_lan}")
      expect(subject).to receive(:puts).with("IPS: #{network_loadbalancer.properties.ips}")
      expect(subject).to receive(:puts).with("Target LAN: #{network_loadbalancer.properties.target_lan}")
      expect(subject).to receive(:puts).with("Private IPS: #{network_loadbalancer.properties.lb_private_ips}")
      expect(subject).to receive(:puts).with("Forwarding Rules: #{[network_loadbalancer.entities.forwardingrules.items[1]].map do |rule|
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
      expect(subject.ui).to receive(:warn).with("Removed Forwarding Rule #{rule.id} from the Network Load balancer #{network_loadbalancer.id}. Request ID: .")

      network_loadbalancer.entities.forwardingrules.items.reject! { |rule| subject.name_args.include?(rule.id) }

      expect(subject).to receive(:get_request_id).once
      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'DELETE',
            path: "/datacenters/#{subject_config[:datacenter_id]}/networkloadbalancers/#{network_loadbalancer.id}/forwardingrules/#{rule.id}",
            operation: :'NetworkLoadBalancersApi.datacenters_networkloadbalancers_forwardingrules_delete',
          },
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/networkloadbalancers/#{network_loadbalancer.id}",
            operation: :'NetworkLoadBalancersApi.datacenters_networkloadbalancers_find_by_network_load_balancer_id',
            return_type: 'NetworkLoadBalancer',
            result: network_loadbalancer,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not call NetworkLoadBalancersApi.datacenters_networkloadbalancers_forwardingrules_delete when the ID is not valid' do
      network_loadbalancer = network_loadbalancer_mock
      rule_id = 'invalid_id'
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        network_loadbalancer_id: network_loadbalancer.id,
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [rule_id]

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
      expect(subject.ui).to receive(:error).with("Forwarding rule ID #{rule_id} not found. Skipping.")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'DELETE',
            path: "/datacenters/#{subject_config[:datacenter_id]}/networkloadbalancers/#{subject_config[:network_loadbalancer_id]}/forwardingrules/#{rule_id}",
            operation: :'NetworkLoadBalancersApi.datacenters_networkloadbalancers_forwardingrules_delete',
            exception: Ionoscloud::ApiError.new(code: 404),
          },
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/networkloadbalancers/#{network_loadbalancer.id}",
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
