require 'spec_helper'
require 'ionoscloud_label_list'

Chef::Knife::IonoscloudLabelList.load_deps

describe Chef::Knife::IonoscloudLabelList do
  before :each do
    subject { Chef::Knife::IonoscloudLabelList.new }

    @labels = labels_mock
    @label_list = [
      subject.ui.color('Resource ID', :bold),
      subject.ui.color('Resource Type', :bold),
      subject.ui.color('Label key', :bold),
      subject.ui.color('Value', :bold),
      @labels.items.first.properties.resource_id,
      @labels.items.first.properties.resource_type,
      @labels.items.first.properties.key,
      @labels.items.first.properties.value,
      @labels.items[1].properties.resource_id,
      @labels.items[1].properties.resource_type,
      @labels.items[1].properties.key,
      @labels.items[1].properties.value,
    ]

    @label_resources = label_resources_mock
    @label_resource_list = [
      subject.ui.color('Resource ID', :bold),
      subject.ui.color('Resource Type', :bold),
      subject.ui.color('Label key', :bold),
      subject.ui.color('Value', :bold),
      'resource_id',
      'resource_type',
      @label_resources.items.first.properties.key,
      @label_resources.items.first.properties.value,
      'resource_id',
      'resource_type',
      @label_resources.items[1].properties.key,
      @label_resources.items[1].properties.value,
    ]

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call LabelsApi.datacenters_labels_get when the type is datacenter and output based on what it receives' do
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        type: 'datacenter',
        resource_id: 'resource_id',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expected_output = @label_resource_list.map { |el| el == 'resource_type' ? subject_config[:type] : el }

      expect(subject.ui).to receive(:list).with(expected_output, :uneven_columns_across, 4)

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:resource_id]}/labels",
            operation: :'LabelsApi.datacenters_labels_get',
            return_type: 'LabelResources',
            result: @label_resources,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should call LabelsApi.datacenters_servers_labels_get when the type is server and output based on what it receives' do
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        type: 'server',
        datacenter_id: 'datacenter_id',
        resource_id: 'resource_id',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expected_output = @label_resource_list.map { |el| el == 'resource_type' ? subject_config[:type] : el }

      expect(subject.ui).to receive(:list).with(expected_output, :uneven_columns_across, 4)

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers/#{subject_config[:resource_id]}/labels",
            operation: :'LabelsApi.datacenters_servers_labels_get',
            return_type: 'LabelResources',
            result: @label_resources,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should call LabelsApi.datacenters_volumes_labels_get when the type is volume and output based on what it receives' do
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        type: 'volume',
        datacenter_id: 'datacenter_id',
        resource_id: 'resource_id',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expected_output = @label_resource_list.map { |el| el == 'resource_type' ? subject_config[:type] : el }

      expect(subject.ui).to receive(:list).with(expected_output, :uneven_columns_across, 4)

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/volumes/#{subject_config[:resource_id]}/labels",
            operation: :'LabelsApi.datacenters_volumes_labels_get',
            return_type: 'LabelResources',
            result: @label_resources,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should call LabelsApi.ipblocks_labels_get when the type is ipblock and output based on what it receives' do
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        type: 'ipblock',
        resource_id: 'resource_id',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expected_output = @label_resource_list.map { |el| el == 'resource_type' ? subject_config[:type] : el }

      expect(subject.ui).to receive(:list).with(expected_output, :uneven_columns_across, 4)

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/ipblocks/#{subject_config[:resource_id]}/labels",
            operation: :'LabelsApi.ipblocks_labels_get',
            return_type: 'LabelResources',
            result: @label_resources,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should call LabelsApi.snapshots_labels_get when the type is snapshot and output based on what it receives' do
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        type: 'snapshot',
        resource_id: 'resource_id',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expected_output = @label_resource_list.map { |el| el == 'resource_type' ? subject_config[:type] : el }

      expect(subject.ui).to receive(:list).with(expected_output, :uneven_columns_across, 4)

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/snapshots/#{subject_config[:resource_id]}/labels",
            operation: :'LabelsApi.snapshots_labels_get',
            return_type: 'LabelResources',
            result: @label_resources,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should call LabelsApi.labels_get when the type is not one of [datacenter, server, volume, ipblock, snapshot]' do
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        type: 'invalid_type',
        resource_id: @labels.items.first.properties.resource_id,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject.ui).to receive(:warn).with("#{subject_config[:type]} is not a valid Resource Type. Returning all available labels.")
      expect(subject.ui).to receive(:list).with(@label_resource_list, :uneven_columns_across, 4)

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: '/labels',
            operation: :'LabelsApi.labels_get',
            return_type: 'Labels',
            result: @labels,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should call LabelsApi.labels_get when the type is missing' do
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        resource_id: @labels.items.first.properties.resource_id,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject.ui).to receive(:list).with(@label_list, :uneven_columns_across, 4)

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: '/labels',
            operation: :'LabelsApi.labels_get',
            return_type: 'Labels',
            result: @labels,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not call anything when the type is one of [datacenter, server, volume, ipblock, snapshot] and resource_id is not given' do
      [
        'datacenter',
        'server',
        'volume',
        'ipblock',
        'snapshot',
      ].each do |resource_type|
        subject_config = {
          ionoscloud_username: 'email',
          ionoscloud_password: 'password',
          type: 'server',
          datacenter_id: 'datacenter_id',
          key: 'key',
          value: 'value',
        }

        subject_config.each { |key, value| subject.config[key] = value }

        expect(subject).to receive(:puts).with("Missing required parameters #{[:resource_id]}")
        expect(subject.api_client).not_to receive(:call_api)

        expect { subject.run }.to raise_error(SystemExit) do |error|
          expect(error.status).to eq(1)
        end

        subject_config.each { |value| subject.config[value] = nil }
      end
    end

    it 'should not call anything when the type is server or volume and datacenter_id is not given' do
      [
        'server',
        'volume',
      ].each do |resource_type|
        subject_config = {
          ionoscloud_username: 'email',
          ionoscloud_password: 'password',
          type: 'server',
          resource_id: 'resource_id',
          key: 'key',
          value: 'value',
        }

        subject_config.each { |key, value| subject.config[key] = value }

        expect(subject).to receive(:puts).with("Missing required parameters #{[:datacenter_id]}")
        expect(subject.api_client).not_to receive(:call_api)

        expect { subject.run }.to raise_error(SystemExit) do |error|
          expect(error.status).to eq(1)
        end

        subject_config.each { |value| subject.config[value] = nil }
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
