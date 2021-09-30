require 'spec_helper'
require 'ionoscloud_volume_get'

Chef::Knife::IonoscloudVolumeGet.load_deps

describe Chef::Knife::IonoscloudVolumeGet do
  before :each do
    subject { Chef::Knife::IonoscloudVolumeGet.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call VolumeApi.datacenters_volumes_find_by_id' do
      volume = volume_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        volume_id: volume.id,
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      check_volume_print(subject, volume)

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/volumes/#{subject_config[:volume_id]}",
            operation: :'VolumeApi.datacenters_volumes_find_by_id',
            return_type: 'Volume',
            result: volume,
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
