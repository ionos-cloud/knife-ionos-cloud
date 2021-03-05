require 'spec_helper'
require 'ionoscloud_server_reboot'

Chef::Knife::IonoscloudServerReboot.load_deps

describe Chef::Knife::IonoscloudServerReboot do
  before :each do
    subject { Chef::Knife::IonoscloudServerReboot.new }

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
        yes: true,
      }
 
      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [server.id]

      expect(subject.ui).to receive(:warn).with("Server #{server.id} is rebooting. Request ID: ")

      expect(subject.api_client).not_to receive(:wait_for)
      expect(subject).to receive(:get_request_id).once
      mock_call_api(
        subject,
        [
          {
            method: 'POST',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers/#{server.id}/reboot",
            operation: :'ServerApi.datacenters_servers_reboot_post',
            return_type: 'Object',
            result: server,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should output failure when the user ID is not valid' do
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
            method: 'POST',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers/#{server_id}/reboot",
            operation: :'ServerApi.datacenters_servers_reboot_post',
            return_type: 'Object',
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
