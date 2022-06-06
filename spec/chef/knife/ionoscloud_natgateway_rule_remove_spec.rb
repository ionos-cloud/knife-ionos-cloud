require 'spec_helper'
require 'ionoscloud_natgateway_rule_remove'

Chef::Knife::IonoscloudNatgatewayRuleRemove.load_deps

describe Chef::Knife::IonoscloudNatgatewayRuleRemove do
  before :each do
    subject { Chef::Knife::IonoscloudNatgatewayRuleRemove.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call NATGatewaysApi.datacenters_natgateways_rules_post when the ID is valid' do
      rule = natgateway_rule_mock
      natgateway = natgateway_mock(rules: [rule])
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        natgateway_id: natgateway.id,
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [rule.id]

      expect(subject).to receive(:puts).with("ID: #{natgateway.id}")
      expect(subject).to receive(:puts).with("Name: #{natgateway.properties.name}")
      expect(subject).to receive(:puts).with("IPS: #{natgateway.properties.public_ips}")
      expect(subject).to receive(:puts).with("LANS: #{natgateway.properties.lans.map { |el| { id: el.id, gateway_ips: el.gateway_ips } }}")
      expect(subject).to receive(:puts).with("Rules: #{[]}")
      expect(subject).to receive(:puts).with("Flowlogs: #{natgateway.entities.flowlogs.items.map { |flowlog| flowlog.id }}")

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'DELETE',
            path: "/datacenters/#{subject_config[:datacenter_id]}/natgateways/#{natgateway.id}/rules/#{rule.id}",
            operation: :'NATGatewaysApi.datacenters_natgateways_rules_delete',
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

      natgateway.entities.rules.items = []

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
