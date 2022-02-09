require 'spec_helper'
require 'ionoscloud_loadbalancer_get'

Chef::Knife::IonoscloudLoadbalancerGet.load_deps

describe Chef::Knife::IonoscloudLoadbalancerGet do
  before :each do
    subject { Chef::Knife::IonoscloudLoadbalancerGet.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call LoadBalancersApi.datacenters_loadbalancers_get' do
      load_balancer = load_balancer_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        loadbalancer_id: load_balancer.id,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      nics = load_balancer.entities.balancednics.items.map { |nic| nic.id }

      expect(subject).to receive(:puts).with("ID: #{load_balancer.id}")
      expect(subject).to receive(:puts).with("Name: #{load_balancer.properties.name}")
      expect(subject).to receive(:puts).with("IP address: #{load_balancer.properties.ip}")
      expect(subject).to receive(:puts).with("DHCP: #{load_balancer.properties.dhcp}")
      expect(subject).to receive(:puts).with("Balanced Nics: #{nics.to_s}")

      mock_call_api(
        subject,
        [
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
