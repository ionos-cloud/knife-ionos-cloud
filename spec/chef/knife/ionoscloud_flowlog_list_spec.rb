require 'spec_helper'
require 'ionoscloud_flowlog_list'

Chef::Knife::IonoscloudFlowlogList.load_deps

describe Chef::Knife::IonoscloudFlowlogList do
  before :each do
    subject { Chef::Knife::IonoscloudFlowlogList.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call FlowLogsApi.datacenters_servers_nics_flowlogs_get' do
      flowlogs = flowlogs_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        server_id: 'server_id',
        nic_id: 'nic_id',
        type: 'nic',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      flowlog_list = [
        subject.ui.color('ID', :bold),
        subject.ui.color('Name', :bold),
        subject.ui.color('Action', :bold),
        subject.ui.color('Direction', :bold),
        subject.ui.color('Bucket', :bold),
      ]

      flowlogs.items.each do |flowlog|
        flowlog_list << flowlog.id
        flowlog_list << flowlog.properties.name
        flowlog_list << flowlog.properties.action.to_s
        flowlog_list << flowlog.properties.direction.to_s
        flowlog_list << flowlog.properties.bucket.to_s
      end

      expect(subject.ui).to receive(:list).with(flowlog_list, :uneven_columns_across, 5)

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers/#{subject_config[:server_id]}/"\
                  "nics/#{subject_config[:nic_id]}/flowlogs",
            operation: :'FlowLogsApi.datacenters_servers_nics_flowlogs_get',
            return_type: 'FlowLogs',
            result: flowlogs,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not call FlowLogsApi.datacenters_servers_nics_flowlogs_get when server_id and nic_id are not given' do
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

    it 'should call NATGatewaysApi.datacenters_natgateways_flowlogs_get' do
      flowlogs = flowlogs_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        natgateway_id: 'natgateway_id',
        type: 'natgateway',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      flowlog_list = [
        subject.ui.color('ID', :bold),
        subject.ui.color('Name', :bold),
        subject.ui.color('Action', :bold),
        subject.ui.color('Direction', :bold),
        subject.ui.color('Bucket', :bold),
      ]

      flowlogs.items.each do |flowlog|
        flowlog_list << flowlog.id
        flowlog_list << flowlog.properties.name
        flowlog_list << flowlog.properties.action.to_s
        flowlog_list << flowlog.properties.direction.to_s
        flowlog_list << flowlog.properties.bucket.to_s
      end

      expect(subject.ui).to receive(:list).with(flowlog_list, :uneven_columns_across, 5)

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/natgateways/#{subject_config[:natgateway_id]}/flowlogs",
            operation: :'NATGatewaysApi.datacenters_natgateways_flowlogs_get',
            return_type: 'FlowLogs',
            result: flowlogs,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not call NATGatewaysApi.datacenters_natgateways_flowlogs_get when natgateway_id is not given' do
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

    it 'should call NetworkLoadBalancersApi.datacenters_servers_nics_flowlogs_get' do
      flowlogs = flowlogs_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        network_loadbalancer_id: 'network_loadbalancer_id',
        type: 'networkloadbalancer',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      flowlog_list = [
        subject.ui.color('ID', :bold),
        subject.ui.color('Name', :bold),
        subject.ui.color('Action', :bold),
        subject.ui.color('Direction', :bold),
        subject.ui.color('Bucket', :bold),
      ]

      flowlogs.items.each do |flowlog|
        flowlog_list << flowlog.id
        flowlog_list << flowlog.properties.name
        flowlog_list << flowlog.properties.action.to_s
        flowlog_list << flowlog.properties.direction.to_s
        flowlog_list << flowlog.properties.bucket.to_s
      end

      expect(subject.ui).to receive(:list).with(flowlog_list, :uneven_columns_across, 5)

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/networkloadbalancers/#{subject_config[:network_loadbalancer_id]}/flowlogs",
            operation: :'NetworkLoadBalancersApi.datacenters_networkloadbalancers_flowlogs_get',
            return_type: 'FlowLogs',
            result: flowlogs,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not call NetworkLoadBalancersApi.datacenters_networkloadbalancers_flowlogs_get when network_loadbalancer_id is not given' do
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

      expect(subject.ui).to receive(:error).with("Flow log cannot belong to #{subject_config[:type]}. Value must be one of ['nic', 'natgateway', 'networkloadbalancer']")

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
