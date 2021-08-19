require 'spec_helper'
require 'ionoscloud_applicationloadbalancer_get'

Chef::Knife::IonoscloudApplicationloadbalancerGet.load_deps

describe Chef::Knife::IonoscloudApplicationloadbalancerGet do
  before :each do
    subject { Chef::Knife::IonoscloudApplicationloadbalancerGet.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call LoadBalancersApi.datacenters_applicationloadbalancers_get' do
      application_load_balancer = application_loadbalancer_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        application_loadbalancer_id: application_load_balancer.id,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{application_load_balancer.id}")
      expect(subject).to receive(:puts).with("Name: #{application_load_balancer.properties.name}")
      expect(subject).to receive(:puts).with("Listener LAN: #{application_load_balancer.properties.listener_lan}")
      expect(subject).to receive(:puts).with("IPS: #{application_load_balancer.properties.ips}")
      expect(subject).to receive(:puts).with("Target LAN: #{application_load_balancer.properties.target_lan}")
      expect(subject).to receive(:puts).with("Lb Private IPS: #{application_load_balancer.properties.lb_private_ips}")
      expect(subject).to receive(:puts).with("Rules: #{subject.get_application_loadbalancer_extended_properties(application_load_balancer)}")

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/applicationloadbalancers/#{subject_config[:application_loadbalancer_id]}",
            operation: :'ApplicationLoadBalancersApi.datacenters_applicationloadbalancers_find_by_application_load_balancer_id',
            return_type: 'ApplicationLoadBalancer',
            result: application_load_balancer,
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
