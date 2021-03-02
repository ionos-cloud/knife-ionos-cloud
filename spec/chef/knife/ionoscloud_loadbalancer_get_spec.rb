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
    it 'should call LoadBalancerApi.datacenters_loadbalancers_get' do
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
            operation: :'LoadBalancerApi.datacenters_loadbalancers_find_by_id',
            return_type: 'Loadbalancer',
            result: load_balancer,
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
