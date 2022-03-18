require 'spec_helper'
require 'ionoscloud_applicationloadbalancer_update'

Chef::Knife::IonoscloudApplicationloadbalancerUpdate.load_deps

describe Chef::Knife::IonoscloudApplicationloadbalancerUpdate do
  before :each do
    subject { Chef::Knife::IonoscloudApplicationloadbalancerUpdate.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call ApplicationLoadBalancersApi.datacenters_applicationloadbalancers_patch' do
      application_loadbalancer = application_loadbalancer_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        application_loadbalancer_id: application_loadbalancer.id,
        name: application_loadbalancer.properties.name + '_edited',
        ips: (application_loadbalancer.properties.ips + ['127.3.3.3']).join(','),
        lb_private_ips: (application_loadbalancer.properties.lb_private_ips + ['127.3.3.3']).join(','),
        listener_lan: application_loadbalancer.properties.listener_lan + 1,
        target_lan: application_loadbalancer.properties.target_lan + 1,
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }


      expect(subject).to receive(:puts).with("ID: #{application_loadbalancer.id}")
      expect(subject).to receive(:puts).with("Name: #{subject_config[:name]}")
      expect(subject).to receive(:puts).with("Listener LAN: #{subject_config[:listener_lan]}")
      expect(subject).to receive(:puts).with("IPS: #{subject_config[:ips].split(',')}")
      expect(subject).to receive(:puts).with("Target LAN: #{subject_config[:target_lan]}")
      expect(subject).to receive(:puts).with("Lb Private IPS: #{subject_config[:lb_private_ips].split(',')}")

      application_loadbalancer.properties.name = subject_config[:name]
      application_loadbalancer.properties.listener_lan = subject_config[:listener_lan]
      application_loadbalancer.properties.target_lan = subject_config[:target_lan]
      application_loadbalancer.properties.ips = subject_config[:ips].split(',')
      application_loadbalancer.properties.lb_private_ips = subject_config[:lb_private_ips].split(',')

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'PATCH',
            path: "/datacenters/#{subject_config[:datacenter_id]}/applicationloadbalancers/#{subject_config[:application_loadbalancer_id]}",
            operation: :'ApplicationLoadBalancersApi.datacenters_applicationloadbalancers_patch',
            return_type: 'ApplicationLoadBalancer',
            body: {
              name: subject_config[:name],
              listenerLan: subject_config[:listener_lan],
              targetLan: subject_config[:target_lan],
              ips: subject_config[:ips].split(','),
              lbPrivateIps: subject_config[:lb_private_ips].split(','),
            },
            result: application_loadbalancer,
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
