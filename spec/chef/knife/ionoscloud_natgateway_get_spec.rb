require 'spec_helper'
require 'ionoscloud_natgateway_get'

Chef::Knife::IonoscloudNatgatewayGet.load_deps

describe Chef::Knife::IonoscloudNatgatewayGet do
  before :each do
    subject { Chef::Knife::IonoscloudNatgatewayGet.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call NATGatewaysApi.datacenters_natgateways_find_by_nat_gateway_id' do
      natgateway = natgateway_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        natgateway_id: natgateway.id,
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{natgateway.id}")
      expect(subject).to receive(:puts).with("Name: #{natgateway.properties.name}")
      expect(subject).to receive(:puts).with("IPS: #{natgateway.properties.public_ips}")
      expect(subject).to receive(:puts).with("LANS: #{natgateway.properties.lans.map { |el| { id: el.id, gateway_ips: el.gateway_ips } }}")
      expect(subject).to receive(:puts).with("Rules: #{natgateway.entities.rules.items.map do |el|
        {
          id: el.id,
          name: el.properties.name,
          type: el.properties.type,
          protocol: el.properties.protocol,
          public_ip: el.properties.public_ip,
          source_subnet: el.properties.source_subnet,
          target_subnet: el.properties.target_subnet,
          target_port_range_start: el.properties.target_port_range ? el.properties.target_port_range.start : '',
          target_port_range_end: el.properties.target_port_range ? el.properties.target_port_range._end : '',
        }
      end}")
      expect(subject).to receive(:puts).with("Flowlogs: #{natgateway.entities.flowlogs.items.map { |flowlog| flowlog.id }}")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/natgateways/#{subject_config[:natgateway_id]}",
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
