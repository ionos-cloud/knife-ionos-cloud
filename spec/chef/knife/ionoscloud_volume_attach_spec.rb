require 'spec_helper'
require 'ionoscloud_volume_attach'

Chef::Knife::IonoscloudVolumeAttach.load_deps

describe Chef::Knife::IonoscloudVolumeAttach do
  before :each do
    subject { Chef::Knife::IonoscloudVolumeAttach.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call ServersApi.datacenters_servers_volumes_post when the ID is valid' do
      volume = volume_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        server_id: 'server_id',
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [volume.id]

      expect(subject.ui).to receive(:msg).with("Volume #{volume.id} attached to server. Request ID: ")

      expect(subject).not_to receive(:wait_for)
      expect(subject).to receive(:get_request_id).once
      mock_call_api(
        subject,
        [
          {
            method: 'POST',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers/#{subject_config[:server_id]}/volumes",
            operation: :'ServersApi.datacenters_servers_volumes_post',
            body: { id: volume.id },
            return_type: 'Volume',
            result: volume,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not call ServersApi.datacenters_servers_volumes_post when the ID is not valid' do
      volume_id = 'invalid_id'
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        server_id: 'server_id',
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [volume_id]

      expect(subject.ui).to receive(:error).with("Volume ID #{volume_id} not found. Skipping.")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'POST',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers/#{subject_config[:server_id]}/volumes",
            operation: :'ServersApi.datacenters_servers_volumes_post',
            body: { id: volume_id },
            return_type: 'Volume',
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
