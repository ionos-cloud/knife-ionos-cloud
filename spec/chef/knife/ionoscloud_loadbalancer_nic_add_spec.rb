require 'spec_helper'
require 'ionoscloud_loadbalancer_nic_add'

Chef::Knife::IonoscloudLoadbalancerNicAdd.load_deps

describe Chef::Knife::IonoscloudLoadbalancerNicAdd do
  before :each do
    subject { Chef::Knife::IonoscloudLoadbalancerNicAdd.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call LoadBalancerApi.datacenters_loadbalancers_delete when the ID is valid' do
      load_balancer = load_balancer_mock
      nic = nic_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        loadbalancer_id: load_balancer.id,
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [nic.id]

      check_loadbalancer_print(subject, load_balancer)
      expect(subject.ui).to receive(:info).with("Added NIC #{nic.id} to the Load balancer #{load_balancer.id}. Request ID: .")

      expect(subject).to receive(:get_request_id).once
      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'POST',
            path: "/datacenters/#{subject_config[:datacenter_id]}/loadbalancers/#{load_balancer.id}/balancednics",
            operation: :'LoadBalancerApi.datacenters_loadbalancers_balancednics_post',
            body: { id: nic.id },
            return_type: 'Nic',
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

    it 'should not call LoadBalancerApi.datacenters_loadbalancers_delete when the ID is not valid' do
      load_balancer = load_balancer_mock
      nic_id = 'invalid_id'
      datacenter_id = 'datacenter_id'

      test_loadbalancer_nic_add_remove_invalid_id(
        subject, load_balancer, datacenter_id, nic_id, :'LoadBalancerApi.datacenters_loadbalancers_balancednics_post',
        "/datacenters/#{datacenter_id}/loadbalancers/#{load_balancer.id}/balancednics",
        'POST', { id: nic_id }, 'Nic',
      )
    end

    it 'should not make any call if any required option is missing' do
      check_required_options(subject)
    end
  end
end
