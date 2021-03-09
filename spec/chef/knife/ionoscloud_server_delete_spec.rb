require 'spec_helper'
require 'ionoscloud_server_delete'

Chef::Knife::IonoscloudServerDelete.load_deps

describe Chef::Knife::IonoscloudServerDelete do
  before :each do
    subject { Chef::Knife::IonoscloudServerDelete.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call ServerApi.datacenters_servers_delete when the ID is valid' do
      server = server_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [server.id]

      expect(subject).to receive(:puts).with("ID: #{server.id}")
      expect(subject).to receive(:puts).with("Name: #{server.properties.name}")
      expect(subject).to receive(:puts).with("Cores: #{server.properties.cores}")
      expect(subject).to receive(:puts).with("CPU Family: #{server.properties.cpu_family}")
      expect(subject).to receive(:puts).with("Ram: #{server.properties.ram}")
      expect(subject).to receive(:puts).with("Availability Zone: #{server.properties.availability_zone}")
      expect(subject).to receive(:puts).with("Boot Volume: #{server.properties.boot_volume.id}")
      expect(subject).to receive(:puts).with("Boot CDROM: #{server.properties.boot_cdrom.id}")
      expect(subject.ui).to receive(:warn).with("Deleted Server #{server.id}. Request ID: ")

      expect(subject.api_client).not_to receive(:wait_for)
      expect(subject).to receive(:get_request_id).once
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers/#{server.id}",
            operation: :'ServerApi.datacenters_servers_find_by_id',
            return_type: 'Server',
            result: server,
          },
          {
            method: 'DELETE',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers/#{server.id}",
            operation: :'ServerApi.datacenters_servers_delete',
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not call ServerApi.datacenters_servers_delete when the user ID is not valid' do
      server_id = 'invalid_id'
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [server_id]

      expect(subject.ui).to receive(:error).with("Server ID #{server_id} not found. Skipping.")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers/#{server_id}",
            operation: :'ServerApi.datacenters_servers_find_by_id',
            return_type: 'Server',
            exception: Ionoscloud::ApiError.new(:code => 404),
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
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
