require 'spec_helper'
require 'ionoscloud_server_console'

Chef::Knife::IonoscloudServerConsole.load_deps

describe Chef::Knife::IonoscloudServerConsole do
  subject { Chef::Knife::IonoscloudServerConsole.new }

  describe '#run' do
    it 'should call ServersApi.datacenters_servers_remote_console_get and output the received url when the server ID is valid' do
      datacenter = datacenter_mock
      server = server_mock
      console = console_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: datacenter.id,
        server_id: server.id,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with(console.url)

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{datacenter.id}/servers/#{server.id}/remoteconsole",
            operation: :'ServersApi.datacenters_servers_remote_console_get',
            return_type: 'RemoteConsoleUrl',
            result: console,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should output an error when the server is not found' do
      datacenter = datacenter_mock
      server_id = 'invalid_id'
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: datacenter.id,
        server_id: server_id,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      allow(subject).to receive(:puts)
      allow(subject).to receive(:print)

      expect(subject.ui).to receive(:error).with("Server ID #{server_id} not found.")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{datacenter.id}/servers/#{server_id}/remoteconsole",
            operation: :'ServersApi.datacenters_servers_remote_console_get',
            return_type: 'RemoteConsoleUrl',
            exception: Ionoscloud::ApiError.new(code: 404),
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not make any call if any required option is missing' do
      required_options = subject.instance_variable_get(:@required_options)

      if required_options.length > 0
        arrays_without_one_element(required_options).each do |test_case|
          subject.config[:ionoscloud_token] = 'token'
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
end
