require 'spec_helper'
require 'ionoscloud_natgateway_rule_list'

Chef::Knife::IonoscloudNatgatewayRuleList.load_deps

describe Chef::Knife::IonoscloudNatgatewayRuleList do
  before :each do
    subject { Chef::Knife::IonoscloudNatgatewayRuleList.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call NATGatewayApi.datacenters_natgateways_get' do
      natgateway_rules = natgateway_rules_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        natgateway_id: 'natgateway_id',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      natgateway_rule_list = [
        subject.ui.color('ID', :bold),
        subject.ui.color('Name', :bold),
        subject.ui.color('Type', :bold),
        subject.ui.color('Protocol', :bold),
        subject.ui.color('Public IP', :bold),
        subject.ui.color('Source Subnet', :bold),
        subject.ui.color('Target Subnet', :bold),
        subject.ui.color('Target Port Range Start', :bold),
        subject.ui.color('Target Port Range End', :bold),
        natgateway_rules.items[0].id,
        natgateway_rules.items[0].properties.name,
        natgateway_rules.items[0].properties.type,
        natgateway_rules.items[0].properties.protocol,
        natgateway_rules.items[0].properties.public_ip,
        natgateway_rules.items[0].properties.source_subnet,
        natgateway_rules.items[0].properties.target_subnet,
        (natgateway_rules.items[0].properties.target_port_range ? natgateway_rules.items[0].properties.target_port_range.start : ''),
        (natgateway_rules.items[0].properties.target_port_range ? natgateway_rules.items[0].properties.target_port_range._end : ''),
        natgateway_rules.items[1].id,
        natgateway_rules.items[1].properties.name,
        natgateway_rules.items[1].properties.type,
        natgateway_rules.items[1].properties.protocol,
        natgateway_rules.items[1].properties.public_ip,
        natgateway_rules.items[1].properties.source_subnet,
        natgateway_rules.items[1].properties.target_subnet,
        (natgateway_rules.items[1].properties.target_port_range ? natgateway_rules.items[1].properties.target_port_range.start : ''),
        (natgateway_rules.items[1].properties.target_port_range ? natgateway_rules.items[1].properties.target_port_range._end : ''),
      ]

      expect(subject.ui).to receive(:list).with(natgateway_rule_list, :uneven_columns_across, 9)

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/natgateways/#{subject_config[:natgateway_id]}/rules",
            operation: :'NATGatewaysApi.datacenters_natgateways_rules_get',
            return_type: 'NatGatewayRules',
            result: natgateway_rules,
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
