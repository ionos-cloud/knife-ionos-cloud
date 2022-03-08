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
    it 'should call LoadBalancersApi.datacenters_loadbalancers_post with the expected arguments and output based on what it receives' do
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

      nics = load_balancer.entities.balancednics.items.map { |nic| nic.id }

      expect(subject).to receive(:puts).with("ID: #{load_balancer.id}")
      expect(subject).to receive(:puts).with("Name: #{load_balancer.properties.name}")
      expect(subject).to receive(:puts).with("IP address: #{load_balancer.properties.ip}")
      expect(subject).to receive(:puts).with("DHCP: #{load_balancer.properties.dhcp}")
      expect(subject).to receive(:puts).with("Balanced Nics: #{nics.to_s}")

      expected_entities = { balancednics: { items: load_balancer.entities.balancednics.items.map { |nic| { id: nic.id } } } }

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'POST',
            path: "/datacenters/#{subject_config[:datacenter_id]}/loadbalancers",
            operation: :'LoadBalancersApi.datacenters_loadbalancers_post',
            return_type: 'Loadbalancer',
            body: { properties: load_balancer.properties.to_hash, entities: expected_entities },
            result: load_balancer,
          },
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/loadbalancers/#{load_balancer.id}",
            operation: :'LoadBalancersApi.datacenters_loadbalancers_find_by_id',
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
