require 'spec_helper'
require 'ionoscloud_flowlog_create'

Chef::Knife::IonoscloudFlowlogCreate.load_deps

describe Chef::Knife::IonoscloudFlowlogCreate do
  before :each do
    subject { Chef::Knife::IonoscloudFlowlogCreate.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call FlowLogsApi.datacenters_servers_nics_flowlogs_post with the expected arguments and output based on what it receives' do
      flowlog = flowlog_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        server_id: 'server_id',
        nic_id: 'nic_id',
        type: 'nic',
        name: flowlog.properties.name,
        action: flowlog.properties.action,
        direction: flowlog.properties.direction,
        bucket: flowlog.properties.bucket,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{flowlog.id}")
      expect(subject).to receive(:puts).with("Name: #{flowlog.properties.name}")
      expect(subject).to receive(:puts).with("Action: #{flowlog.properties.action}")
      expect(subject).to receive(:puts).with("Direction: #{flowlog.properties.direction}")
      expect(subject).to receive(:puts).with("Bucket: #{flowlog.properties.bucket}")

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'POST',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers/#{subject_config[:server_id]}/nics/#{subject_config[:nic_id]}/flowlogs",
            operation: :'FlowLogsApi.datacenters_servers_nics_flowlogs_post',
            return_type: 'FlowLog',
            body: { properties: flowlog.properties.to_hash },
            result: flowlog,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not call FlowLogsApi.datacenters_servers_nics_flowlogs_post when server_id and nic_id are not given' do
      flowlog = flowlog_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        type: 'nic',
        name: flowlog.properties.name,
        action: flowlog.properties.action,
        direction: flowlog.properties.direction,
        bucket: flowlog.properties.bucket,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("Missing required parameters #{[:server_id, :nic_id]}")

      expect(subject.api_client).not_to receive(:call_api)

      expect { subject.run }.to raise_error(SystemExit) do |error|
        expect(error.status).to eq(1)
      end
    end

    it 'should call NATGatewaysApi.datacenters_natgateways_flowlogs_post with the expected arguments and output based on what it receives' do
      flowlog = flowlog_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        natgateway_id: 'natgateway_id',
        type: 'natgateway',
        name: flowlog.properties.name,
        action: flowlog.properties.action,
        direction: flowlog.properties.direction,
        bucket: flowlog.properties.bucket,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{flowlog.id}")
      expect(subject).to receive(:puts).with("Name: #{flowlog.properties.name}")
      expect(subject).to receive(:puts).with("Action: #{flowlog.properties.action}")
      expect(subject).to receive(:puts).with("Direction: #{flowlog.properties.direction}")
      expect(subject).to receive(:puts).with("Bucket: #{flowlog.properties.bucket}")

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'POST',
            path: "/datacenters/#{subject_config[:datacenter_id]}/natgateways/#{subject_config[:natgateway_id]}/flowlogs",
            operation: :'NATGatewaysApi.datacenters_natgateways_flowlogs_post',
            return_type: 'FlowLog',
            body: { properties: flowlog.properties.to_hash },
            result: flowlog,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not call NATGatewaysApi.datacenters_natgateways_flowlogs_post when natgateway_id is not given' do
      flowlog = flowlog_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        type: 'natgateway',
        name: flowlog.properties.name,
        action: flowlog.properties.action,
        direction: flowlog.properties.direction,
        bucket: flowlog.properties.bucket,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("Missing required parameters #{[:natgateway_id]}")

      expect(subject.api_client).not_to receive(:call_api)

      expect { subject.run }.to raise_error(SystemExit) do |error|
        expect(error.status).to eq(1)
      end
    end

    it 'should call NetworkLoadBalancersApi.datacenters_networkloadbalancers_flowlogs_post with the expected arguments and output based on what it receives' do
      flowlog = flowlog_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        network_loadbalancer_id: 'network_loadbalancer_id',
        type: 'loadbalancer',
        name: flowlog.properties.name,
        action: flowlog.properties.action,
        direction: flowlog.properties.direction,
        bucket: flowlog.properties.bucket,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{flowlog.id}")
      expect(subject).to receive(:puts).with("Name: #{flowlog.properties.name}")
      expect(subject).to receive(:puts).with("Action: #{flowlog.properties.action}")
      expect(subject).to receive(:puts).with("Direction: #{flowlog.properties.direction}")
      expect(subject).to receive(:puts).with("Bucket: #{flowlog.properties.bucket}")

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'POST',
            path: "/datacenters/#{subject_config[:datacenter_id]}/networkloadbalancers/#{subject_config[:network_loadbalancer_id]}/flowlogs",
            operation: :'NetworkLoadBalancersApi.datacenters_networkloadbalancers_flowlogs_post',
            return_type: 'FlowLog',
            body: { properties: flowlog.properties.to_hash },
            result: flowlog,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not call NetworkLoadBalancersApi.datacenters_networkloadbalancers_flowlogs_post when network_loadbalancer_id is not given' do
      flowlog = flowlog_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        type: 'loadbalancer',
        name: flowlog.properties.name,
        action: flowlog.properties.action,
        direction: flowlog.properties.direction,
        bucket: flowlog.properties.bucket,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("Missing required parameters #{[:network_loadbalancer_id]}")

      expect(subject.api_client).not_to receive(:call_api)

      expect { subject.run }.to raise_error(SystemExit) do |error|
        expect(error.status).to eq(1)
      end
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
        nic_id: 'nic_id',
        type: 'other',
        name: flowlog.properties.name,
        action: flowlog.properties.action,
        direction: flowlog.properties.direction,
        bucket: flowlog.properties.bucket,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject.ui).to receive(:error).with("Flow log cannot belong to #{subject_config[:type]}. Value must be one of ['nic', 'natgateway', 'loadbalancer']")

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
