require 'spec_helper'
require 'ionoscloud_networkloadbalancer_list'

Chef::Knife::IonoscloudNetworkloadbalancerList.load_deps

describe Chef::Knife::IonoscloudNetworkloadbalancerList do
  before :each do
    subject { Chef::Knife::IonoscloudNetworkloadbalancerList.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call NetworkLoadBalancersApi.datacenters_networkloadbalancers_get' do
      network_loadbalancers = network_loadbalancers_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      network_loadbalancer_list = [
        subject.ui.color('ID', :bold),
        subject.ui.color('Name', :bold),
        subject.ui.color('Listener LAN', :bold),
        subject.ui.color('Target LAN', :bold),
        subject.ui.color('Rules', :bold),
        subject.ui.color('Flowlogs', :bold),
        subject.ui.color('IPS', :bold),
        subject.ui.color('Private IPS', :bold),
        network_loadbalancers.items.first.id,
        network_loadbalancers.items.first.properties.name,
        network_loadbalancers.items.first.properties.listener_lan,
        network_loadbalancers.items.first.properties.target_lan,
        network_loadbalancers.items.first.entities.forwardingrules.items.length,
        network_loadbalancers.items.first.entities.flowlogs.items.length,
        network_loadbalancers.items.first.properties.ips,
        network_loadbalancers.items.first.properties.lb_private_ips,
        network_loadbalancers.items[1].id,
        network_loadbalancers.items[1].properties.name,
        network_loadbalancers.items[1].properties.listener_lan,
        network_loadbalancers.items[1].properties.target_lan,
        network_loadbalancers.items[1].entities.forwardingrules.items.length,
        network_loadbalancers.items[1].entities.flowlogs.items.length,
        network_loadbalancers.items[1].properties.ips,
        network_loadbalancers.items[1].properties.lb_private_ips,
      ]

      expect(subject.ui).to receive(:list).with(network_loadbalancer_list, :uneven_columns_across, 8)

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/networkloadbalancers",
            operation: :'NetworkLoadBalancersApi.datacenters_networkloadbalancers_get',
            return_type: 'NetworkLoadBalancers',
            result: network_loadbalancers,
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
