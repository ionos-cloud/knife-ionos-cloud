require 'spec_helper'
require 'ionoscloud_volume_create'

Chef::Knife::IonoscloudVolumeCreate.load_deps

describe Chef::Knife::IonoscloudVolumeCreate do
  before :each do
    subject { Chef::Knife::IonoscloudVolumeCreate.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call VolumeApi.datacenters_volumes_post with the expected arguments and output based on what it receives' do
      volume = volume_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        name: volume.properties.name,
        size: volume.properties.size,
        type: volume.properties.type,
        bus: volume.properties.bus,
        availability_zone: volume.properties.availability_zone,
        image_alias: 'debian:latest',
        image_password: 'K3tTj8G14a3EgKyNeeiY',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expected_body = volume.properties.to_hash
      expected_body.delete(:image)
      expected_body.delete(:licenceType)

      expected_body[:imageAlias] = subject_config[:image_alias]
      expected_body[:imagePassword] = subject_config[:image_password]

      check_volume_print(subject, volume)

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'POST',
            path: "/datacenters/#{subject_config[:datacenter_id]}/volumes",
            operation: :'VolumeApi.datacenters_volumes_post',
            return_type: 'Volume',
            body: { properties: expected_body },
            result: volume,
          },
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/volumes/#{volume.id}",
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
