require 'spec_helper'
require 'ionoscloud_applicationloadbalancer_list'

Chef::Knife::IonoscloudApplicationloadbalancerList.load_deps

describe Chef::Knife::IonoscloudApplicationloadbalancerList do
  before :each do
    subject { Chef::Knife::IonoscloudApplicationloadbalancerList.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call ApplicationLoadBalancersApi.datacenters_applicationloadbalancers_get' do
      application_loadbalancers = application_loadbalancers_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      application_loadbalancer_list = [
        subject.ui.color('ID', :bold),
        subject.ui.color('Name', :bold),
        subject.ui.color('Listener LAN', :bold),
        subject.ui.color('Target LAN', :bold),
        subject.ui.color('Rules', :bold),
        subject.ui.color('IPS', :bold),
        subject.ui.color('Private IPS', :bold),
        application_loadbalancers.items.first.id,
        application_loadbalancers.items.first.properties.name,
        application_loadbalancers.items.first.properties.listener_lan,
        application_loadbalancers.items.first.properties.target_lan,
        application_loadbalancers.items.first.entities.forwardingrules.items.length,
        application_loadbalancers.items.first.properties.ips,
        application_loadbalancers.items.first.properties.lb_private_ips,
        application_loadbalancers.items[1].id,
        application_loadbalancers.items[1].properties.name,
        application_loadbalancers.items[1].properties.listener_lan,
        application_loadbalancers.items[1].properties.target_lan,
        application_loadbalancers.items[1].entities.forwardingrules.items.length,
        application_loadbalancers.items[1].properties.ips,
        application_loadbalancers.items[1].properties.lb_private_ips,
      ]

      expect(subject.ui).to receive(:list).with(application_loadbalancer_list, :uneven_columns_across, 7)

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/applicationloadbalancers",
            operation: :'ApplicationLoadBalancersApi.datacenters_applicationloadbalancers_get',
            return_type: 'ApplicationLoadBalancers',
            result: application_loadbalancers,
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
