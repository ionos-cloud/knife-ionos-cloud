require 'spec_helper'
require 'ionoscloud_server_upgrade'

Chef::Knife::IonoscloudServerUpgrade.load_deps

describe Chef::Knife::IonoscloudServerUpgrade do
  before :each do
    subject { Chef::Knife::IonoscloudServerUpgrade.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should output success when the ID is valid' do
      server = server_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        server_id: server.id,
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [server.id]

      expect(subject.ui).to receive(:info).with("Server #{server.id} is being upgraded. Request ID: ")

      expect(subject.api_client).not_to receive(:wait_for)
      expect(subject).to receive(:get_request_id).once

      mock_call_api(
        subject,
        [
          {
            method: 'POST',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers/#{server.id}/upgrade",
            operation: :'ServersApi.datacenters_servers_upgrade_post',
            result: server,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should output failure when the server ID is not valid' do
      server_id = 'invalid_id'
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        server_id: server_id,
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [server_id]

      expect(subject.ui).to receive(:error).with("Server ID #{server_id} not found.")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'POST',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers/#{server_id}/upgrade",
            operation: :'ServersApi.datacenters_servers_upgrade_post',
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
