require 'spec_helper'
require 'ionoscloud_server_token'

Chef::Knife::IonoscloudServerToken.load_deps

describe Chef::Knife::IonoscloudServerToken do
  subject { Chef::Knife::IonoscloudServerToken.new }

  describe '#run' do
    it 'should call ServersApi.datacenters_servers_token_get and output the received url when the server ID is valid' do
      datacenter = datacenter_mock
      server = server_mock
      token = token_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: datacenter.id,
        server_id: server.id,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with(token.token)

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{datacenter.id}/servers/#{server.id}/token",
            operation: :'ServersApi.datacenters_servers_token_get',
            return_type: 'Token',
            result: token,
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
            path: "/datacenters/#{datacenter.id}/servers/#{server_id}/token",
            operation: :'ServersApi.datacenters_servers_token_get',
            return_type: 'Token',
            exception: Ionoscloud::ApiError.new(code: 404),
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not make any call if any required option is missing' do
      check_required_options(subject)
    end
  end
end
