require 'spec_helper'
require 'ionoscloud_loadbalancer_list'

Chef::Knife::IonoscloudLoadbalancerList.load_deps

describe Chef::Knife::IonoscloudLoadbalancerList do
  before :each do
    subject { Chef::Knife::IonoscloudLoadbalancerList.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call LoadBalancersApi.datacenters_loadbalancers_get' do
      load_balancers = load_balancers_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      load_balancer_list = [
        subject.ui.color('ID', :bold),
        subject.ui.color('Name', :bold),
        subject.ui.color('IP address', :bold),
        subject.ui.color('DHCP', :bold),
        subject.ui.color('NICs count', :bold),
        load_balancers.items.first.id,
        load_balancers.items.first.properties.name,
        load_balancers.items.first.properties.ip,
        load_balancers.items.first.properties.dhcp.to_s,
        load_balancers.items.first.entities.balancednics.items.length.to_s,
      ]

      expect(subject.ui).to receive(:list).with(load_balancer_list, :uneven_columns_across, 5)

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/loadbalancers",
            operation: :'LoadBalancersApi.datacenters_loadbalancers_get',
            return_type: 'Loadbalancers',
            result: load_balancers,
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
