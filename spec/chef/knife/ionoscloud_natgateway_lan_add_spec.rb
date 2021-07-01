require 'spec_helper'
require 'ionoscloud_natgateway_lan_add'

Chef::Knife::IonoscloudNatgatewayLanAdd.load_deps

describe Chef::Knife::IonoscloudNatgatewayLanAdd do
  before :each do
    subject { Chef::Knife::IonoscloudNatgatewayLanAdd.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call NATGatewaysApi.datacenters_natgateways_patch and add a new lan when need' do
      natgateway = natgateway_mock
      lan = natgateway_lan_mock(lan_id: 2, gateway_ips: ['0.8.152.237/24'])
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        natgateway_id: natgateway.id,
        lan_id: lan.id,
        gateway_ips: lan.gateway_ips.join(','),
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{natgateway.id}")
      expect(subject).to receive(:puts).with("Name: #{natgateway.properties.name}")
      expect(subject).to receive(:puts).with("IPS: #{natgateway.properties.public_ips}")
      expect(subject).to receive(:puts).with("LANS: #{(natgateway.properties.lans + [lan]).map { |el| { id: el.id, gateway_ips: el.gateway_ips } }}")

      expected_properties = natgateway.properties.to_hash
      expected_properties[:lans] << lan.to_hash

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/natgateways/#{natgateway.id}",
            operation: :'NATGatewaysApi.datacenters_natgateways_find_by_nat_gateway_id',
            return_type: 'NatGateway',
            result: natgateway,
          },
          {
            method: 'PATCH',
            path: "/datacenters/#{subject_config[:datacenter_id]}/natgateways/#{natgateway.id}",
            operation: :'NATGatewaysApi.datacenters_natgateways_patch',
            body: expected_properties,
            return_type: 'NatGateway',
            result: natgateway,
          },
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/natgateways/#{natgateway.id}",
            operation: :'NATGatewaysApi.datacenters_natgateways_find_by_nat_gateway_id',
            return_type: 'NatGateway',
            result: natgateway,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should call NATGatewaysApi.datacenters_natgateways_patch and update an existing lan when need' do
      natgateway = natgateway_mock
      lan = natgateway_lan_mock(lan_id: 1, gateway_ips: ['0.8.152.237/24'])
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        natgateway_id: natgateway.id,
        lan_id: lan.id,
        gateway_ips: lan.gateway_ips.join(','),
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{natgateway.id}")
      expect(subject).to receive(:puts).with("Name: #{natgateway.properties.name}")
      expect(subject).to receive(:puts).with("IPS: #{natgateway.properties.public_ips}")
      expect(subject).to receive(:puts).with("LANS: #{[{ id: lan.id, gateway_ips: lan.gateway_ips }]}")

      expected_properties = natgateway.properties.to_hash
      expected_properties[:lans] = [lan.to_hash]

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/natgateways/#{natgateway.id}",
            operation: :'NATGatewaysApi.datacenters_natgateways_find_by_nat_gateway_id',
            return_type: 'NatGateway',
            result: natgateway,
          },
          {
            method: 'PATCH',
            path: "/datacenters/#{subject_config[:datacenter_id]}/natgateways/#{natgateway.id}",
            operation: :'NATGatewaysApi.datacenters_natgateways_patch',
            body: expected_properties,
            return_type: 'NatGateway',
            result: natgateway,
          },
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/natgateways/#{natgateway.id}",
            operation: :'NATGatewaysApi.datacenters_natgateways_find_by_nat_gateway_id',
            return_type: 'NatGateway',
            result: natgateway,
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
