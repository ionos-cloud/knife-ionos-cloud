require 'spec_helper'
require 'ionoscloud_natgateway_list'

Chef::Knife::IonoscloudNatgatewayList.load_deps

describe Chef::Knife::IonoscloudNatgatewayList do
  before :each do
    subject { Chef::Knife::IonoscloudNatgatewayList.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call NATGatewayApi.datacenters_natgateways_get' do
      natgateways = natgateways_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      natgateway_list = [
        subject.ui.color('ID', :bold),
        subject.ui.color('Name', :bold),
        subject.ui.color('IPS', :bold),
        subject.ui.color('LANS', :bold),
        subject.ui.color('Rules Count', :bold),
        natgateways.items.first.id,
        natgateways.items.first.properties.name,
        natgateways.items.first.properties.public_ips,
        natgateways.items.first.properties.lans.map { |el| { id: el.id, gateway_ips: el.gateway_ips } },
        natgateways.items.first.entities.rules.items.length,
        natgateways.items[1].id,
        natgateways.items[1].properties.name,
        natgateways.items[1].properties.public_ips,
        natgateways.items[1].properties.lans.map { |el| { id: el.id, gateway_ips: el.gateway_ips } },
        natgateways.items[1].entities.rules.items.length,
      ]

      expect(subject.ui).to receive(:list).with(natgateway_list, :uneven_columns_across, 5)

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/natgateways",
            operation: :'NATGatewaysApi.datacenters_natgateways_get',
            return_type: 'NatGateways',
            result: natgateways,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not make any call if any required option is missing' do
      required_options = subject.instance_variable_get(:@required_options)

      if required_options.length > 0
        arrays_without_one_element(required_options).each do |test_case|
          subject.config[:ionoscloud_token] = 'token'
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
end
