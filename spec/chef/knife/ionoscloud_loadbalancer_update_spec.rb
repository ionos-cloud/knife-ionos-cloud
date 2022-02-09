require 'spec_helper'
require 'ionoscloud_loadbalancer_update'

Chef::Knife::IonoscloudLoadbalancerUpdate.load_deps

describe Chef::Knife::IonoscloudLoadbalancerUpdate do
  before :each do
    subject { Chef::Knife::IonoscloudLoadbalancerUpdate.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call LoadBalancersApi.datacenters_loadbalancers_patch' do
      load_balancer = load_balancer_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        loadbalancer_id: load_balancer.id,
        name: load_balancer.properties.name + '_edited',
        dhcp: (!load_balancer.properties.dhcp).to_s,
        ip: '127.0.0.3',
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      nics = load_balancer.entities.balancednics.items.map { |nic| nic.id }

      expect(subject).to receive(:puts).with("ID: #{load_balancer.id}")
      expect(subject).to receive(:puts).with("Name: #{subject_config[:name]}")
      expect(subject).to receive(:puts).with("IP address: #{subject_config[:ip]}")
      expect(subject).to receive(:puts).with("DHCP: #{subject_config[:dhcp]}")
      expect(subject).to receive(:puts).with("Balanced Nics: #{nics.to_s}")

      load_balancer.properties.name = subject_config[:name]
      load_balancer.properties.dhcp = subject_config[:dhcp].to_s.downcase == 'true'
      load_balancer.properties.ip = subject_config[:ip]

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'PATCH',
            path: "/datacenters/#{subject_config[:datacenter_id]}/loadbalancers/#{subject_config[:loadbalancer_id]}",
            operation: :'LoadBalancersApi.datacenters_loadbalancers_patch',
            return_type: 'Loadbalancer',
            body: {
              name: subject_config[:name],
              dhcp: subject_config[:dhcp].to_s.downcase == 'true',
              ip: subject_config[:ip],
            },
            result: load_balancer,
          },
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/loadbalancers/#{subject_config[:loadbalancer_id]}",
            operation: :'LoadBalancersApi.datacenters_loadbalancers_find_by_id',
            return_type: 'Loadbalancer',
            result: load_balancer,
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
