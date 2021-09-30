require 'spec_helper'
require 'ionoscloud_label_add'

Chef::Knife::IonoscloudLabelAdd.load_deps

def test_label_create(type, resource_id, extra_config, path, operation)
  label = label_resource_mock
  subject_config = {
    ionoscloud_username: 'email',
    ionoscloud_password: 'password',
    type: type,
    resource_id: resource_id,
    key: label.properties.key,
    value: label.properties.value,
    **extra_config,
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
        path: path,
        operation: operation,
        return_type: 'LabelResource',
        body: { properties: expected_body },
        result: label,
      },
    ],
  )

  expect { subject.run }.not_to raise_error(Exception)
end

describe Chef::Knife::IonoscloudLabelAdd do
  before :each do
    subject { Chef::Knife::IonoscloudLabelAdd.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call LabelApi.datacenters_labels_post when the type is datacenter and output based on what it receives' do
      resource_id = 'resource_id'

      test_label_create(
        type = 'datacenter',
        resource_id = 'resource_id',
        extra_config = {},
        path = "/datacenters/#{resource_id}/labels",
        operation = :'LabelApi.datacenters_labels_post',
      )
    end

    it 'should call LabelApi.datacenters_servers_labels_post when the type is server and output based on what it receives' do
      resource_id = 'resource_id'
      datacenter_id = 'datacenter_id'

      test_label_create(
        type = 'server',
        resource_id = 'resource_id',
        extra_config = { datacenter_id: datacenter_id },
        path = "/datacenters/#{datacenter_id}/servers/#{resource_id}/labels",
        operation = :'LabelApi.datacenters_servers_labels_post',
      )
    end

    it 'should call LabelApi.datacenters_volumes_labels_post when the type is volume and output based on what it receives' do
      resource_id = 'resource_id'
      datacenter_id = 'datacenter_id'

      test_label_create(
        type = 'volume',
        resource_id = 'resource_id',
        extra_config = { datacenter_id: datacenter_id },
        path = "/datacenters/#{datacenter_id}/volumes/#{resource_id}/labels",
        operation = :'LabelApi.datacenters_volumes_labels_post',
      )
    end

    it 'should call LabelApi.ipblocks_labels_post when the type is ipblock and output based on what it receives' do
      resource_id = 'resource_id'

      test_label_create(
        type = 'ipblock',
        resource_id = 'resource_id',
        extra_config = {},
        path = "/ipblocks/#{resource_id}/labels",
        operation = :'LabelApi.ipblocks_labels_post',
      )
    end

    it 'should call LabelApi.snapshots_labels_post when the type is snapshot and output based on what it receives' do
      resource_id = 'resource_id'

      test_label_create(
        type = 'snapshot',
        resource_id = 'resource_id',
        extra_config = {},
        path = "/snapshots/#{resource_id}/labels",
        operation = :'LabelApi.snapshots_labels_post',
      )
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
      check_required_options(subject)
    end
  end
end
