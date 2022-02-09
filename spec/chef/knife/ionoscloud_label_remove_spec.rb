require 'spec_helper'
require 'ionoscloud_label_remove'

Chef::Knife::IonoscloudLabelRemove.load_deps

describe Chef::Knife::IonoscloudLabelRemove do
  before :each do
    subject { Chef::Knife::IonoscloudLabelRemove.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call LabelsApi.datacenters_labels_delete when the type is datacenter and output based on what it receives' do
      label = label_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        type: 'datacenter',
        resource_id: label.properties.resource_id,
        key: label.properties.key,
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [label.id]

      expect(subject.ui).to receive(:warn).with("Removed Label #{label.id} from #{subject_config[:type]} #{subject_config[:resource_id]}.")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'DELETE',
            path: "/datacenters/#{subject_config[:resource_id]}/labels/#{label.id}",
            operation: :'LabelsApi.datacenters_labels_delete',
            result: label,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should print when LabelsApi.datacenters_labels_delete returns 404' do
      label = label_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        type: 'datacenter',
        resource_id: label.properties.resource_id,
        key: label.properties.key,
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [label.id]

      expect(subject.ui).to receive(:error).with("Label #{label.id} not found. Skipping.")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'DELETE',
            path: "/datacenters/#{subject_config[:resource_id]}/labels/#{label.id}",
            operation: :'LabelsApi.datacenters_labels_delete',
            exception: Ionoscloud::ApiError.new(code: 404),
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should call LabelsApi.datacenters_servers_labels_delete when the type is datacenter and output based on what it receives' do
      label = label_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        type: 'server',
        datacenter_id: 'datacenter_id',
        resource_id: label.properties.resource_id,
        key: label.properties.key,
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [label.id]

      expect(subject.ui).to receive(:warn).with("Removed Label #{label.id} from #{subject_config[:type]} #{subject_config[:resource_id]}.")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'DELETE',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers/#{subject_config[:resource_id]}/labels/#{label.id}",
            operation: :'LabelsApi.datacenters_servers_labels_delete',
            result: label,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should print when LabelsApi.datacenters_servers_labels_delete returns 404' do
      label = label_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        type: 'server',
        datacenter_id: 'datacenter_id',
        resource_id: label.properties.resource_id,
        key: label.properties.key,
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [label.id]

      expect(subject.ui).to receive(:error).with("Label #{label.id} not found. Skipping.")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'DELETE',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers/#{subject_config[:resource_id]}/labels/#{label.id}",
            operation: :'LabelsApi.datacenters_servers_labels_delete',
            exception: Ionoscloud::ApiError.new(code: 404),
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should call LabelsApi.datacenters_volumes_labels_delete when the type is datacenter and output based on what it receives' do
      label = label_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        type: 'volume',
        datacenter_id: 'datacenter_id',
        resource_id: label.properties.resource_id,
        key: label.properties.key,
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [label.id]

      expect(subject.ui).to receive(:warn).with("Removed Label #{label.id} from #{subject_config[:type]} #{subject_config[:resource_id]}.")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'DELETE',
            path: "/datacenters/#{subject_config[:datacenter_id]}/volumes/#{subject_config[:resource_id]}/labels/#{label.id}",
            operation: :'LabelsApi.datacenters_volumes_labels_delete',
            result: label,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should print when LabelsApi.datacenters_volumes_labels_delete returns 404' do
      label = label_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        type: 'volume',
        datacenter_id: 'datacenter_id',
        resource_id: label.properties.resource_id,
        key: label.properties.key,
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [label.id]

      expect(subject.ui).to receive(:error).with("Label #{label.id} not found. Skipping.")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'DELETE',
            path: "/datacenters/#{subject_config[:datacenter_id]}/volumes/#{subject_config[:resource_id]}/labels/#{label.id}",
            operation: :'LabelsApi.datacenters_volumes_labels_delete',
            exception: Ionoscloud::ApiError.new(code: 404),
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end
    it 'should call LabelsApi.ipblocks_labels_delete when the type is ipblock and output based on what it receives' do
      label = label_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        type: 'ipblock',
        resource_id: label.properties.resource_id,
        key: label.properties.key,
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [label.id]

      expect(subject.ui).to receive(:warn).with("Removed Label #{label.id} from #{subject_config[:type]} #{subject_config[:resource_id]}.")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'DELETE',
            path: "/ipblocks/#{subject_config[:resource_id]}/labels/#{label.id}",
            operation: :'LabelsApi.ipblocks_labels_delete',
            result: label,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should print when LabelsApi.ipblocks_labels_delete returns 404' do
      label = label_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        type: 'ipblock',
        resource_id: label.properties.resource_id,
        key: label.properties.key,
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [label.id]

      expect(subject.ui).to receive(:error).with("Label #{label.id} not found. Skipping.")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'DELETE',
            path: "/ipblocks/#{subject_config[:resource_id]}/labels/#{label.id}",
            operation: :'LabelsApi.ipblocks_labels_delete',
            exception: Ionoscloud::ApiError.new(code: 404),
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should call LabelsApi.snapshots_labels_delete when the type is snapshot and output based on what it receives' do
      label = label_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        type: 'snapshot',
        resource_id: label.properties.resource_id,
        key: label.properties.key,
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [label.id]

      expect(subject.ui).to receive(:warn).with("Removed Label #{label.id} from #{subject_config[:type]} #{subject_config[:resource_id]}.")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'DELETE',
            path: "/snapshots/#{subject_config[:resource_id]}/labels/#{label.id}",
            operation: :'LabelsApi.snapshots_labels_delete',
            result: label,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should print when LabelsApi.snapshots_labels_delete returns 404' do
      label = label_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        type: 'snapshot',
        resource_id: label.properties.resource_id,
        key: label.properties.key,
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [label.id]

      expect(subject.ui).to receive(:error).with("Label #{label.id} not found. Skipping.")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'DELETE',
            path: "/snapshots/#{subject_config[:resource_id]}/labels/#{label.id}",
            operation: :'LabelsApi.snapshots_labels_delete',
            exception: Ionoscloud::ApiError.new(code: 404),
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
