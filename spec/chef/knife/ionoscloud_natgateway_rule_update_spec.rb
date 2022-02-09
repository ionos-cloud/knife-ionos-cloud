require 'spec_helper'
require 'ionoscloud_natgateway_rule_update'

Chef::Knife::IonoscloudNatgatewayRuleUpdate.load_deps

describe Chef::Knife::IonoscloudNatgatewayRuleUpdate do
  before :each do
    subject { Chef::Knife::IonoscloudNatgatewayRuleUpdate.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call NATGatewaysApi.datacenters_natgateways_rules_patch' do
      natgateway = natgateway_mock
      natgateway_rule = natgateway.entities.rules.items[0]

      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        natgateway_id: natgateway.id,
        natgateway_rule_id: natgateway_rule.id,
        name: natgateway_rule.properties.name + '_edited',
        type: 'SNAT',
        protocol: 'UDP',
        source_subnet: '127.0.0.3/24',
        public_ip: '127.0.0.3',
        target_subnet: '127.0.0.3/24',
        target_port_range_start: natgateway_rule.properties.target_port_range.start + 10,
        target_port_range_end: natgateway_rule.properties.target_port_range._end + 1,
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      natgateway.entities.rules.items[0].properties.name = subject_config[:name]
      natgateway.entities.rules.items[0].properties.type = subject_config[:type]
      natgateway.entities.rules.items[0].properties.protocol = subject_config[:protocol]
      natgateway.entities.rules.items[0].properties.source_subnet = subject_config[:source_subnet]
      natgateway.entities.rules.items[0].properties.public_ip = subject_config[:public_ip]
      natgateway.entities.rules.items[0].properties.target_subnet = subject_config[:target_subnet]
      natgateway.entities.rules.items[0].properties.target_port_range.start = subject_config[:target_port_range_start]
      natgateway.entities.rules.items[0].properties.target_port_range._end = subject_config[:target_port_range_end]

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

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'PATCH',
            path: "/datacenters/#{subject_config[:datacenter_id]}/natgateways/#{subject_config[:natgateway_id]}/"\
            "rules/#{subject_config[:natgateway_rule_id]}",
            operation: :'NATGatewaysApi.datacenters_natgateways_rules_patch',
            return_type: 'NatGatewayRule',
            body: {
              name: subject_config[:name],
              type: subject_config[:type],
              protocol: subject_config[:protocol],
              publicIp: subject_config[:public_ip],
              sourceSubnet: subject_config[:source_subnet],
              targetSubnet: subject_config[:target_subnet],
              targetPortRange: {
                start: subject_config[:target_port_range_start],
                end: subject_config[:target_port_range_end],
              }
            },
            result: natgateway,
          },
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
