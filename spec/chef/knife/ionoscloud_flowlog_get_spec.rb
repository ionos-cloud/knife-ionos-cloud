require 'spec_helper'
require 'ionoscloud_flowlog_get'

Chef::Knife::IonoscloudFlowlogGet.load_deps

describe Chef::Knife::IonoscloudFlowlogGet do
  before :each do
    subject { Chef::Knife::IonoscloudFlowlogGet.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call FlowLogsApi.datacenters_servers_nics_flowlogs_find_by_id' do
      flowlog = flowlog_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        type: 'nic',
        datacenter_id: 'datacenter_id',
        server_id: 'server_id',
        nic_id: 'nic_id',
        flowlog_id: flowlog.id,
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{flowlog.id}")
      expect(subject).to receive(:puts).with("Name: #{flowlog.properties.name}")
      expect(subject).to receive(:puts).with("Action: #{flowlog.properties.action}")
      expect(subject).to receive(:puts).with("Direction: #{flowlog.properties.direction}")
      expect(subject).to receive(:puts).with("Bucket: #{flowlog.properties.bucket}")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
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

    it 'should call NATGatewaysApi.datacenters_natgateways_flowlogs_find_by_flow_log_id' do
      flowlog = flowlog_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        type: 'natgateway',
        datacenter_id: 'datacenter_id',
        natgateway_id: 'natgateway_id',
        flowlog_id: flowlog.id,
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{flowlog.id}")
      expect(subject).to receive(:puts).with("Name: #{flowlog.properties.name}")
      expect(subject).to receive(:puts).with("Action: #{flowlog.properties.action}")
      expect(subject).to receive(:puts).with("Direction: #{flowlog.properties.direction}")
      expect(subject).to receive(:puts).with("Bucket: #{flowlog.properties.bucket}")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
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

    it 'should call NetworkLoadBalancersApi.datacenters_networkloadbalancers_flowlogs_find_by_flow_log_id' do
      flowlog = flowlog_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        type: 'networkloadbalancer',
        datacenter_id: 'datacenter_id',
        network_loadbalancer_id: 'network_loadbalancer_id',
        flowlog_id: flowlog.id,
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{flowlog.id}")
      expect(subject).to receive(:puts).with("Name: #{flowlog.properties.name}")
      expect(subject).to receive(:puts).with("Action: #{flowlog.properties.action}")
      expect(subject).to receive(:puts).with("Direction: #{flowlog.properties.direction}")
      expect(subject).to receive(:puts).with("Bucket: #{flowlog.properties.bucket}")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
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
