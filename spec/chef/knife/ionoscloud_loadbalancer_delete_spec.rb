require 'spec_helper'
require 'ionoscloud_loadbalancer_delete'

Chef::Knife::IonoscloudLoadbalancerDelete.load_deps

describe Chef::Knife::IonoscloudLoadbalancerDelete do
  before :each do
    subject { Chef::Knife::IonoscloudLoadbalancerDelete.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call LoadBalancersApi.datacenters_loadbalancers_delete when the ID is valid' do
      load_balancer = load_balancer_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [load_balancer.id]

      nics = load_balancer.entities.balancednics.items.map { |nic| nic.id }

      expect(subject).to receive(:puts).with("ID: #{load_balancer.id}")
      expect(subject).to receive(:puts).with("Name: #{load_balancer.properties.name}")
      expect(subject).to receive(:puts).with("IP address: #{load_balancer.properties.ip}")
      expect(subject).to receive(:puts).with("DHCP: #{load_balancer.properties.dhcp}")
      expect(subject).to receive(:puts).with("Balanced Nics: #{nics.to_s}")
      expect(subject.ui).to receive(:warn).with("Deleted Load balancer #{load_balancer.id}. Request ID: ")

      expect(subject.api_client).not_to receive(:wait_for)
      expect(subject).to receive(:get_request_id).once
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/loadbalancers/#{load_balancer.id}",
            operation: :'LoadBalancersApi.datacenters_loadbalancers_find_by_id',
            return_type: 'Loadbalancer',
            result: load_balancer,
          },
          {
            method: 'DELETE',
            path: "/datacenters/#{subject_config[:datacenter_id]}/loadbalancers/#{load_balancer.id}",
            operation: :'LoadBalancersApi.datacenters_loadbalancers_delete',
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not call LoadBalancersApi.datacenters_loadbalancers_delete when the ID is not valid' do
      load_balancer_id = 'invalid_id'
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [load_balancer_id]

      expect(subject.ui).to receive(:error).with("Load balancer ID #{load_balancer_id} not found. Skipping.")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/loadbalancers/#{load_balancer_id}",
            operation: :'LoadBalancersApi.datacenters_loadbalancers_find_by_id',
            return_type: 'Loadbalancer',
            exception: Ionoscloud::ApiError.new(code: 404),
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
