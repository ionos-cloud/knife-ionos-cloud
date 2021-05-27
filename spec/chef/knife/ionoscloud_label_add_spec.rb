require 'spec_helper'
require 'ionoscloud_label_add'

Chef::Knife::IonoscloudLabelAdd.load_deps

describe Chef::Knife::IonoscloudLabelAdd do
  before :each do
    subject { Chef::Knife::IonoscloudLabelAdd.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call LabelsApi.datacenters_labels_post when the type is datacenter and output based on what it receives' do
      label = label_resource_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        type: 'datacenter',
        resource_id: 'resource_id',
        key: label.properties.key,
        value: label.properties.value,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("Resource ID: #{subject_config[:resource_id]}")
      expect(subject).to receive(:puts).with("Resource Type: #{subject_config[:type]}")
      expect(subject).to receive(:puts).with("Label Key: #{subject_config[:key]}")
      expect(subject).to receive(:puts).with("Value: #{subject_config[:value]}")

      expected_body = {
        key: subject_config[:key],
        value: subject_config[:value],
      }

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'POST',
            path: "/datacenters/#{subject_config[:resource_id]}/labels",
            operation: :'LabelsApi.datacenters_labels_post',
            return_type: 'LabelResource',
            body: { properties: expected_body },
            result: label,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should call LabelsApi.datacenters_servers_labels_post when the type is server and output based on what it receives' do
      label = label_resource_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        type: 'server',
        datacenter_id: 'datacenter_id',
        resource_id: 'resource_id',
        key: label.properties.key,
        value: label.properties.value,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("Resource ID: #{subject_config[:resource_id]}")
      expect(subject).to receive(:puts).with("Resource Type: #{subject_config[:type]}")
      expect(subject).to receive(:puts).with("Label Key: #{subject_config[:key]}")
      expect(subject).to receive(:puts).with("Value: #{subject_config[:value]}")

      expected_body = {
        key: subject_config[:key],
        value: subject_config[:value],
      }

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'POST',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers/#{subject_config[:resource_id]}/labels",
            operation: :'LabelsApi.datacenters_servers_labels_post',
            return_type: 'LabelResource',
            body: { properties: expected_body },
            result: label,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should call LabelsApi.datacenters_volumes_labels_post when the type is volume and output based on what it receives' do
      label = label_resource_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        type: 'volume',
        datacenter_id: 'datacenter_id',
        resource_id: 'resource_id',
        key: label.properties.key,
        value: label.properties.value,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("Resource ID: #{subject_config[:resource_id]}")
      expect(subject).to receive(:puts).with("Resource Type: #{subject_config[:type]}")
      expect(subject).to receive(:puts).with("Label Key: #{subject_config[:key]}")
      expect(subject).to receive(:puts).with("Value: #{subject_config[:value]}")

      expected_body = {
        key: subject_config[:key],
        value: subject_config[:value],
      }

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'POST',
            path: "/datacenters/#{subject_config[:datacenter_id]}/volumes/#{subject_config[:resource_id]}/labels",
            operation: :'LabelsApi.datacenters_volumes_labels_post',
            return_type: 'LabelResource',
            body: { properties: expected_body },
            result: label,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should call LabelsApi.ipblocks_labels_post when the type is ipblock and output based on what it receives' do
      label = label_resource_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        type: 'ipblock',
        resource_id: 'resource_id',
        key: label.properties.key,
        value: label.properties.value,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("Resource ID: #{subject_config[:resource_id]}")
      expect(subject).to receive(:puts).with("Resource Type: #{subject_config[:type]}")
      expect(subject).to receive(:puts).with("Label Key: #{subject_config[:key]}")
      expect(subject).to receive(:puts).with("Value: #{subject_config[:value]}")

      expected_body = {
        key: subject_config[:key],
        value: subject_config[:value],
      }

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'POST',
            path: "/ipblocks/#{subject_config[:resource_id]}/labels",
            operation: :'LabelsApi.ipblocks_labels_post',
            return_type: 'LabelResource',
            body: { properties: expected_body },
            result: label,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should call LabelsApi.snapshots_labels_post when the type is snapshot and output based on what it receives' do
      label = label_resource_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        type: 'snapshot',
        resource_id: 'resource_id',
        key: label.properties.key,
        value: label.properties.value,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("Resource ID: #{subject_config[:resource_id]}")
      expect(subject).to receive(:puts).with("Resource Type: #{subject_config[:type]}")
      expect(subject).to receive(:puts).with("Label Key: #{subject_config[:key]}")
      expect(subject).to receive(:puts).with("Value: #{subject_config[:value]}")

      expected_body = {
        key: subject_config[:key],
        value: subject_config[:value],
      }

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'POST',
            path: "/snapshots/#{subject_config[:resource_id]}/labels",
            operation: :'LabelsApi.snapshots_labels_post',
            return_type: 'LabelResource',
            body: { properties: expected_body },
            result: label,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not call anything when the type is not one of [datacenter, server, volume, ipblock, snapshot]' do
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        type: 'invalid_type',
        resource_id: 'resource_id',
        key: 'key',
        value: 'value',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject.ui).to receive(:error).with("#{subject_config[:type]} is not a valid Resource Type.")
      expect(subject.api_client).not_to receive(:call_api)

      expect { subject.run }.to raise_error(SystemExit) do |error|
        expect(error.status).to eq(1)
      end
    end

    it 'should not call anything when the type is server or volume and datacenter_id is not given' do
      types = [
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
