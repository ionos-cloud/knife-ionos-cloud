require 'spec_helper'
require 'ionoscloud_flowlog_delete'

Chef::Knife::IonoscloudFlowlogDelete.load_deps

describe Chef::Knife::IonoscloudFlowlogDelete do
  before :each do
    subject { Chef::Knife::IonoscloudFlowlogDelete.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call FlowLogsApi.datacenters_servers_nics_flowlogs_flowlogs_delete when the ID is valid' do
      flowlog = flowlog_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        server_id: 'server_id',
        nic_id: 'nic_id',
        type: 'nic',
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [flowlog.id]

      expect(subject).to receive(:puts).with("ID: #{flowlog.id}")
      expect(subject).to receive(:puts).with("Name: #{flowlog.properties.name}")
      expect(subject).to receive(:puts).with("Action: #{flowlog.properties.action}")
      expect(subject).to receive(:puts).with("Direction: #{flowlog.properties.direction}")
      expect(subject).to receive(:puts).with("Bucket: #{flowlog.properties.bucket}")
      expect(subject.ui).to receive(:warn).with("Deleted Flow Log #{flowlog.id}. Request ID: ")

      expect(subject.api_client).not_to receive(:wait_for)
      expect(subject).to receive(:get_request_id).once
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
          {
            method: 'DELETE',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers/#{subject_config[:server_id]}/"\
                  "nics/#{subject_config[:nic_id]}/flowlogs/#{flowlog.id}",
            operation: :'FlowLogsApi.datacenters_servers_nics_flowlogs_delete',
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not call FlowLogsApi.datacenters_servers_nics_flowlogs_delete when the ID is not valid' do
      flowlog_id = 'invalid_id'
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        server_id: 'server_id',
        nic_id: 'nic_id',
        type: 'nic',
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [flowlog_id]

      expect(subject.ui).to receive(:error).with("Flow Log ID #{flowlog_id} not found. Skipping.")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers/#{subject_config[:server_id]}/"\
                  "nics/#{subject_config[:nic_id]}/flowlogs/#{flowlog_id}",
            operation: :'FlowLogsApi.datacenters_servers_nics_flowlogs_find_by_id',
            return_type: 'FlowLog',
            exception: Ionoscloud::ApiError.new(code: 404),
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not call FlowLogsApi.datacenters_servers_nics_flowlogs_delete when server_id and nic_id are not given' do
      flowlog_id = 'invalid_id'
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        type: 'nic',
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [flowlog_id]

      expect(subject).to receive(:puts).with("Missing required parameters #{[:server_id, :nic_id]}")

      expect(subject.api_client).not_to receive(:call_api)

      expect { subject.run }.to raise_error(SystemExit) do |error|
        expect(error.status).to eq(1)
      end
    end

    it 'should call NATGatewaysApi.datacenters_natgateways_flowlogs_flowlogs_delete when the ID is valid' do
      flowlog = flowlog_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        natgateway_id: 'natgateway_id',
        type: 'natgateway',
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [flowlog.id]

      expect(subject).to receive(:puts).with("ID: #{flowlog.id}")
      expect(subject).to receive(:puts).with("Name: #{flowlog.properties.name}")
      expect(subject).to receive(:puts).with("Action: #{flowlog.properties.action}")
      expect(subject).to receive(:puts).with("Direction: #{flowlog.properties.direction}")
      expect(subject).to receive(:puts).with("Bucket: #{flowlog.properties.bucket}")
      expect(subject.ui).to receive(:warn).with("Deleted Flow Log #{flowlog.id}. Request ID: ")

      expect(subject.api_client).not_to receive(:wait_for)
      expect(subject).to receive(:get_request_id).once
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
          {
            method: 'DELETE',
            path: "/datacenters/#{subject_config[:datacenter_id]}/natgateways/#{subject_config[:natgateway_id]}/flowlogs/#{flowlog.id}",
            operation: :'NATGatewaysApi.datacenters_natgateways_flowlogs_delete',
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not call NATGatewaysApi.datacenters_natgateways_flowlogs_delete when the ID is not valid' do
      flowlog_id = 'invalid_id'
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        natgateway_id: 'natgateway_id',
        type: 'natgateway',
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [flowlog_id]

      expect(subject.ui).to receive(:error).with("Flow Log ID #{flowlog_id} not found. Skipping.")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/natgateways/#{subject_config[:natgateway_id]}/flowlogs/#{flowlog_id}",
            operation: :'NATGatewaysApi.datacenters_natgateways_flowlogs_find_by_flow_log_id',
            return_type: 'FlowLog',
            exception: Ionoscloud::ApiError.new(code: 404),
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not call NATGatewaysApi.datacenters_natgateways_flowlogs_delete when natgateway_id is not given' do
      flowlog_id = 'invalid_id'
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        type: 'natgateway',
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [flowlog_id]

      expect(subject).to receive(:puts).with("Missing required parameters #{[:natgateway_id]}")

      expect(subject.api_client).not_to receive(:call_api)

      expect { subject.run }.to raise_error(SystemExit) do |error|
        expect(error.status).to eq(1)
      end
    end

    it 'should call NetworkLoadBalancersApi.datacenters_networkloadbalancers_flowlogs_flowlogs_delete when the ID is valid' do
      flowlog = flowlog_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        network_loadbalancer_id: 'network_loadbalancer_id',
        type: 'networkloadbalancer',
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [flowlog.id]

      expect(subject).to receive(:puts).with("ID: #{flowlog.id}")
      expect(subject).to receive(:puts).with("Name: #{flowlog.properties.name}")
      expect(subject).to receive(:puts).with("Action: #{flowlog.properties.action}")
      expect(subject).to receive(:puts).with("Direction: #{flowlog.properties.direction}")
      expect(subject).to receive(:puts).with("Bucket: #{flowlog.properties.bucket}")
      expect(subject.ui).to receive(:warn).with("Deleted Flow Log #{flowlog.id}. Request ID: ")

      expect(subject.api_client).not_to receive(:wait_for)
      expect(subject).to receive(:get_request_id).once
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
        nic_id: 'nic_id',
            path: "/datacenters/#{subject_config[:datacenter_id]}/networkloadbalancers/#{subject_config[:network_loadbalancer_id]}/flowlogs/#{flowlog.id}",
            operation: :'NetworkLoadBalancersApi.datacenters_networkloadbalancers_flowlogs_find_by_flow_log_id',
            return_type: 'FlowLog',
            result: flowlog,
          },
          {
            method: 'DELETE',
        nic_id: 'nic_id',
            path: "/datacenters/#{subject_config[:datacenter_id]}/networkloadbalancers/#{subject_config[:network_loadbalancer_id]}/flowlogs/#{flowlog.id}",
            operation: :'NetworkLoadBalancersApi.datacenters_networkloadbalancers_flowlogs_delete',
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not call NetworkLoadBalancersApi.datacenters_networkloadbalancers_flowlogs_delete when the ID is not valid' do
      flowlog_id = 'invalid_id'
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        network_loadbalancer_id: 'network_loadbalancer_id',
        type: 'networkloadbalancer',
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [flowlog_id]

      expect(subject.ui).to receive(:error).with("Flow Log ID #{flowlog_id} not found. Skipping.")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
        nic_id: 'nic_id',
            path: "/datacenters/#{subject_config[:datacenter_id]}/networkloadbalancers/#{subject_config[:network_loadbalancer_id]}/flowlogs/#{flowlog_id}",
            operation: :'NetworkLoadBalancersApi.datacenters_networkloadbalancers_flowlogs_find_by_flow_log_id',
            return_type: 'FlowLog',
            exception: Ionoscloud::ApiError.new(code: 404),
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not call NetworkLoadBalancersApi.datacenters_networkloadbalancers_flowlogs_delete when network_loadbalancer_id is not given' do
      flowlog_id = 'invalid_id'
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        type: 'networkloadbalancer',
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [flowlog_id]

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

      expect(subject.ui).to receive(:error).with("Flow Log cannot belong to #{subject_config[:type]}. Value must be one of ['nic', 'natgateway', 'networkloadbalancer']")

      expect(subject.api_client).not_to receive(:call_api)

      expect { subject.run }.to raise_error(SystemExit) do |error|
        expect(error.status).to eq(1)
      end
    end

    it 'should not make any call if any required option is missing' do
      check_required_options(subject)
    end
  end
end
