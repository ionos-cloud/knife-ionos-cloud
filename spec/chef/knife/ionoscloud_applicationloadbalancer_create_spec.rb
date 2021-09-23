require 'spec_helper'
require 'ionoscloud_applicationloadbalancer_create'

Chef::Knife::IonoscloudApplicationloadbalancerCreate.load_deps

describe Chef::Knife::IonoscloudApplicationloadbalancerCreate do
  before :each do
    subject { Chef::Knife::IonoscloudApplicationloadbalancerCreate.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call ApplicationLoadBalancersApi.datacenters_applicationloadbalancers_post with the expected arguments and output based on what it receives' do
      application_loadbalancer = application_loadbalancer_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        name: application_loadbalancer.properties.name,
        ips: application_loadbalancer.properties.ips.join(','),
        listener_lan: application_loadbalancer.properties.listener_lan,
        target_lan: application_loadbalancer.properties.target_lan,
        lb_private_ips: application_loadbalancer.properties.lb_private_ips.join(','),
      }.each do |key, value|
        subject.config[key] = value
      end

      expect(subject).to receive(:puts).with("ID: #{application_loadbalancer.id}")
      expect(subject).to receive(:puts).with("Name: #{application_loadbalancer.properties.name}")
      expect(subject).to receive(:puts).with("Listener LAN: #{application_loadbalancer.properties.listener_lan}")
      expect(subject).to receive(:puts).with("IPS: #{application_loadbalancer.properties.ips}")
      expect(subject).to receive(:puts).with("Target LAN: #{application_loadbalancer.properties.target_lan}")
      expect(subject).to receive(:puts).with("Lb Private IPS: #{application_loadbalancer.properties.lb_private_ips}")

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'POST',
            path: "/datacenters/#{subject_config[:datacenter_id]}/applicationloadbalancers",
            operation: :'ApplicationLoadBalancersApi.datacenters_applicationloadbalancers_post',
            return_type: 'ApplicationLoadBalancer',
            body: { properties: application_loadbalancer.properties.to_hash },
            result: application_loadbalancer,
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
