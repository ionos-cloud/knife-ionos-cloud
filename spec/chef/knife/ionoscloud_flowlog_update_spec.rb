require 'spec_helper'
require 'ionoscloud_flowlog_update'

Chef::Knife::IonoscloudFlowlogUpdate.load_deps

describe Chef::Knife::IonoscloudFlowlogUpdate do
  before :each do
    subject { Chef::Knife::IonoscloudFlowlogUpdate.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call FlowLogsApi.datacenters_servers_nics_flowlogs_patch' do
      flowlog = flowlog_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        type: 'nic',
        datacenter_id: 'datacenter_id',
        server_id: 'server_id',
        nic_id: 'nic_id',
        flowlog_id: flowlog.id,
        name: flowlog.properties.name + '_edited',
        action: 'REJECTED',
        direction: 'BIDIRECTIONAL',
        bucket: 'new_bucket_name',
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{flowlog.id}")
      expect(subject).to receive(:puts).with("Name: #{subject_config[:name]}")
      expect(subject).to receive(:puts).with("Action: #{subject_config[:action]}")
      expect(subject).to receive(:puts).with("Direction: #{subject_config[:direction]}")
      expect(subject).to receive(:puts).with("Bucket: #{subject_config[:bucket]}")

      flowlog.properties.name = subject_config[:name]
      flowlog.properties.action = subject_config[:action]
      flowlog.properties.direction = subject_config[:direction]
      flowlog.properties.bucket = subject_config[:bucket]

      expected_body = {
        name: subject_config[:name],
        action: subject_config[:action],
        direction: subject_config[:direction],
        bucket: subject_config[:bucket],
      }

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'PATCH',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers/#{subject_config[:server_id]}/"\
            "nics/#{subject_config[:nic_id]}/flowlogs/#{flowlog.id}",
            operation: :'FlowLogsApi.datacenters_servers_nics_flowlogs_patch',
            return_type: 'FlowLog',
            body: expected_body,
            result: flowlog,
          },
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers/#{subject_config[:server_id]}/"\
                  "nics/#{subject_config[:nic_id]}/flowlogs/#{flowlog.id}",
            operation: :'FlowLogsApi.datacenters_servers_nics_flowlogs_find_by_id',
            return_type: 'FlowLog',
            result: flowlog,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should call NATGatewaysApi.datacenters_natgateways_flowlogs_patch' do
      flowlog = flowlog_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        type: 'natgateway',
        datacenter_id: 'datacenter_id',
        natgateway_id: 'natgateway_id',
        flowlog_id: flowlog.id,
        name: flowlog.properties.name + '_edited',
        action: 'REJECTED',
        direction: 'BIDIRECTIONAL',
        bucket: 'new_bucket_name',
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{flowlog.id}")
      expect(subject).to receive(:puts).with("Name: #{subject_config[:name]}")
      expect(subject).to receive(:puts).with("Action: #{subject_config[:action]}")
      expect(subject).to receive(:puts).with("Direction: #{subject_config[:direction]}")
      expect(subject).to receive(:puts).with("Bucket: #{subject_config[:bucket]}")

      flowlog.properties.name = subject_config[:name]
      flowlog.properties.action = subject_config[:action]
      flowlog.properties.direction = subject_config[:direction]
      flowlog.properties.bucket = subject_config[:bucket]

      expected_body = {
        name: subject_config[:name],
        action: subject_config[:action],
        direction: subject_config[:direction],
        bucket: subject_config[:bucket],
      }

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'PATCH',
            path: "/datacenters/#{subject_config[:datacenter_id]}/natgateways/#{subject_config[:natgateway_id]}/flowlogs/#{flowlog.id}",
            operation: :'NATGatewaysApi.datacenters_natgateways_flowlogs_patch',
            return_type: 'FlowLog',
            body: expected_body,
            result: flowlog,
          },
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/natgateways/#{subject_config[:natgateway_id]}/flowlogs/#{flowlog.id}",
            operation: :'NATGatewaysApi.datacenters_natgateways_flowlogs_find_by_flow_log_id',
            return_type: 'FlowLog',
            result: flowlog,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should call NetworkLoadBalancersApi.datacenters_networkloadbalancers_flowlogs_patch' do
      flowlog = flowlog_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        type: 'networkloadbalancer',
        datacenter_id: 'datacenter_id',
        network_loadbalancer_id: 'network_loadbalancer_id',
        flowlog_id: flowlog.id,
        name: flowlog.properties.name + '_edited',
        action: 'REJECTED',
        direction: 'BIDIRECTIONAL',
        bucket: 'new_bucket_name',
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{flowlog.id}")
      expect(subject).to receive(:puts).with("Name: #{subject_config[:name]}")
      expect(subject).to receive(:puts).with("Action: #{subject_config[:action]}")
      expect(subject).to receive(:puts).with("Direction: #{subject_config[:direction]}")
      expect(subject).to receive(:puts).with("Bucket: #{subject_config[:bucket]}")

      flowlog.properties.name = subject_config[:name]
      flowlog.properties.action = subject_config[:action]
      flowlog.properties.direction = subject_config[:direction]
      flowlog.properties.bucket = subject_config[:bucket]

      expected_body = {
        name: subject_config[:name],
        action: subject_config[:action],
        direction: subject_config[:direction],
        bucket: subject_config[:bucket],
      }

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'PATCH',
            path: "/datacenters/#{subject_config[:datacenter_id]}/networkloadbalancers/#{subject_config[:network_loadbalancer_id]}/flowlogs/#{flowlog.id}",
            operation: :'NetworkLoadBalancersApi.datacenters_networkloadbalancers_flowlogs_patch',
            return_type: 'FlowLog',
            body: expected_body,
            result: flowlog,
          },
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/networkloadbalancers/#{subject_config[:network_loadbalancer_id]}/flowlogs/#{flowlog.id}",
            operation: :'NetworkLoadBalancersApi.datacenters_networkloadbalancers_flowlogs_find_by_flow_log_id',
            return_type: 'FlowLog',
            result: flowlog,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not call anything when the wrong type is given' do
      flowlog = flowlog_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        server_id: 'server_id',
        natgateway_id: 'natgateway_id',
        network_loadbalancer_id: 'network_loadbalancer_id',
        flowlog_id: 'flowlog_id',
        nic_id: 'nic_id',
        type: 'other',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject.ui).to receive(:error).with("Flow Log cannot belong to #{subject_config[:type]}. Value must be one of ['nic', 'natgateway', 'networkloadbalancer']")

      expect(subject.api_client).not_to receive(:call_api)

      expect { subject.run }.to raise_error(SystemExit) do |error|
        expect(error.status).to eq(1)
      end
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
