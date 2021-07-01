require 'spec_helper'
require 'ionoscloud_natgateway_create'

Chef::Knife::IonoscloudNatgatewayCreate.load_deps

describe Chef::Knife::IonoscloudNatgatewayCreate do
  before :each do
    subject { Chef::Knife::IonoscloudNatgatewayCreate.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call NATGatewaysApi.datacenters_natgateways_post with the expected arguments and output based on what it receives' do
      natgateway = natgateway_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        name: natgateway.properties.name,
        ips: natgateway.properties.public_ips.join(','),
      }.each do |key, value|
        subject.config[key] = value
      end

      expect(subject).to receive(:puts).with("ID: #{natgateway.id}")
      expect(subject).to receive(:puts).with("Name: #{natgateway.properties.name}")
      expect(subject).to receive(:puts).with("IPS: #{natgateway.properties.public_ips}")

      expected_properties = natgateway.properties.to_hash
      expected_properties.delete(:lans)

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'POST',
            path: "/datacenters/#{subject_config[:datacenter_id]}/natgateways",
            operation: :'NATGatewaysApi.datacenters_natgateways_post',
            return_type: 'NatGateway',
            body: { properties: expected_properties },
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
