require 'spec_helper'
require 'ionoscloud_loadbalancer_create'

Chef::Knife::IonoscloudLoadbalancerCreate.load_deps

describe Chef::Knife::IonoscloudLoadbalancerCreate do
  before :each do
    subject { Chef::Knife::IonoscloudLoadbalancerCreate.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call KubernetesApi.k8s_nodepools_post with the expected arguments and output based on what it receives' do
      load_balancer = load_balancer_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        name: load_balancer.properties.name,
        ip: load_balancer.properties.ip,
        dhcp: load_balancer.properties.dhcp,
        nics: load_balancer.entities.balancednics.items.map { |nic| nic.id }.join(','),
      }.each do |key, value|
        subject.config[key] = value
      end

      check_loadbalancer_print(subject, load_balancer)

      expected_entities = { balancednics: { items: load_balancer.entities.balancednics.items.map { |nic| { id: nic.id } } } }

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'POST',
            path: "/datacenters/#{subject_config[:datacenter_id]}/loadbalancers",
            operation: :'LoadBalancerApi.datacenters_loadbalancers_post',
            return_type: 'Loadbalancer',
            body: { properties: load_balancer.properties.to_hash, entities: expected_entities },
            result: load_balancer,
          },
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/loadbalancers/#{load_balancer.id}",
            operation: :'LoadBalancerApi.datacenters_loadbalancers_find_by_id',
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
