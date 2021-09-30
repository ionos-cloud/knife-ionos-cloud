require 'spec_helper'
require 'ionoscloud_volume_detach'

Chef::Knife::IonoscloudVolumeDetach.load_deps

describe Chef::Knife::IonoscloudVolumeDetach do
  before :each do
    subject { Chef::Knife::IonoscloudVolumeDetach.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call ServerApi.datacenters_servers_volumes_delete when the ID is valid' do
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

      check_volume_print(subject, volume)
      expect(subject.ui).to receive(:msg).with("Detaching Volume #{volume.id} from server. Request ID: ")

      expect(subject).not_to receive(:wait_for)
      expect(subject).to receive(:get_request_id).once
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers/#{subject_config[:server_id]}/volumes/#{volume.id}",
            operation: :'ServerApi.datacenters_servers_volumes_find_by_id',
            return_type: 'Volume',
            result: volume,
          },
          {
            method: 'DELETE',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers/#{subject_config[:server_id]}/volumes/#{volume.id}",
            operation: :'ServerApi.datacenters_servers_volumes_delete',
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not call ServerApi.datacenters_servers_volumes_delete when the ID is not valid' do
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
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers/#{subject_config[:server_id]}/volumes/#{volume_id}",
            operation: :'ServerApi.datacenters_servers_volumes_find_by_id',
            return_type: 'Volume',
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
