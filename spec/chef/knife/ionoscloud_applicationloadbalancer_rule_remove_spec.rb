require 'spec_helper'
require 'ionoscloud_applicationloadbalancer_rule_remove'

Chef::Knife::IonoscloudApplicationloadbalancerRuleRemove.load_deps

describe Chef::Knife::IonoscloudApplicationloadbalancerRuleRemove do
  before :each do
    subject { Chef::Knife::IonoscloudApplicationloadbalancerRuleRemove.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call ApplicationLoadBalancersApi.datacenters_applicationloadbalancers_delete when the ID is valid' do
      application_loadbalancer = application_loadbalancer_mock
      application_loadbalancer_rule = application_loadbalancer_rule_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        application_loadbalancer_id: application_loadbalancer.id,
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [application_loadbalancer_rule.id]

      expect(subject).to receive(:puts).with("ID: #{application_loadbalancer.id}")
      expect(subject).to receive(:puts).with("Name: #{application_loadbalancer.properties.name}")
      expect(subject).to receive(:puts).with("Listener LAN: #{application_loadbalancer.properties.listener_lan}")
      expect(subject).to receive(:puts).with("IPS: #{application_loadbalancer.properties.ips}")
      expect(subject).to receive(:puts).with("Target LAN: #{application_loadbalancer.properties.target_lan}")
      expect(subject).to receive(:puts).with("Lb Private IPS: #{application_loadbalancer.properties.lb_private_ips}")
      expect(subject).to receive(:puts).with("Rules: #{subject.get_application_loadbalancer_extended_properties(application_loadbalancer)}")
      expect(subject).to receive(:print).with("Removing rules #{subject.name_args} from the Application Loadbalancer...")

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'DELETE',
            path: "/datacenters/#{subject_config[:datacenter_id]}/applicationloadbalancers/#{application_loadbalancer.id}/forwardingrules/#{application_loadbalancer_rule.id}",
            operation: :'ApplicationLoadBalancersApi.datacenters_applicationloadbalancers_forwardingrules_delete',
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

    it 'should not call ApplicationLoadBalancersApi.datacenters_applicationloadbalancers_delete when the ID is not valid' do
      application_loadbalancer = application_loadbalancer_mock
      rule_id = 'invalid_id'
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        application_loadbalancer_id: application_loadbalancer.id,
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [rule_id]

      expect(subject).to receive(:puts).with("ID: #{application_loadbalancer.id}")
      expect(subject).to receive(:puts).with("Name: #{application_loadbalancer.properties.name}")
      expect(subject).to receive(:puts).with("Listener LAN: #{application_loadbalancer.properties.listener_lan}")
      expect(subject).to receive(:puts).with("IPS: #{application_loadbalancer.properties.ips}")
      expect(subject).to receive(:puts).with("Target LAN: #{application_loadbalancer.properties.target_lan}")
      expect(subject).to receive(:puts).with("Lb Private IPS: #{application_loadbalancer.properties.lb_private_ips}")
      expect(subject).to receive(:puts).with("Rules: #{subject.get_application_loadbalancer_extended_properties(application_loadbalancer)}")

      expect(subject.ui).to receive(:warn).with("Error removing Forwarding Rule #{rule_id}. Skipping.")
      expect(subject.ui).to receive(:warn).with('No valid rules to remove.')

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'DELETE',
            path: "/datacenters/#{subject_config[:datacenter_id]}/applicationloadbalancers/#{subject_config[:application_loadbalancer_id]}/forwardingrules/#{rule_id}",
            operation: :'ApplicationLoadBalancersApi.datacenters_applicationloadbalancers_forwardingrules_delete',
            exception: Ionoscloud::ApiError.new(code: 404),
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
