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

      expect(subject).to receive(:puts).with("ID: #{volume.id}")
      expect(subject).to receive(:puts).with("Name: #{subject_config[:name]}")
      expect(subject).to receive(:puts).with("Size: #{subject_config[:size]}")
      expect(subject).to receive(:puts).with("Bus: #{subject_config[:bus]}")
      expect(subject).to receive(:puts).with("Image: #{volume.properties.image}")
      expect(subject).to receive(:puts).with("Type: #{subject_config[:type]}")
      expect(subject).to receive(:puts).with("Licence Type: #{volume.properties.licence_type}")
      expect(subject).to receive(:puts).with("Zone: #{subject_config[:availability_zone]}")

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

    it 'should not call anything when neither image not image-alias is provided' do
      volume = volume_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        cluster_id: 'cluster_id',
        datacenter_id: 'datacenter_id',
        name: volume.properties.name,
        size: volume.properties.size,
        type: volume.properties.type,
        bus: volume.properties.bus,
        availability_zone: volume.properties.availability_zone,
        image_password: 'K3tTj8G14a3EgKyNeeiY',
      }

      subject_config.each { |key, value| subject.config[key] = value }
      expect(subject.ui).to receive(:error).with('Either \'--image\' or \'--image-alias\' parameter must be provided')

      expect(subject.api_client).not_to receive(:wait_for)
      expect(subject.api_client).not_to receive(:call_api)

      expect { subject.run }.to raise_error(SystemExit) do |error|
        expect(error.status).to eq(1)
      end
    end

    it 'should not call anything when neither image not image-alias is provided' do
      volume = volume_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        cluster_id: 'cluster_id',
        datacenter_id: 'datacenter_id',
        name: volume.properties.name,
        size: volume.properties.size,
        type: volume.properties.type,
        bus: volume.properties.bus,
        availability_zone: volume.properties.availability_zone,
        image_alias: 'debian:latest',
      }

      subject_config.each { |key, value| subject.config[key] = value }
      expect(subject.ui).to receive(:error).with('Either \'--image-password\' or \'--ssh-keys\' parameter must be provided')

      expect(subject.api_client).not_to receive(:wait_for)
      expect(subject.api_client).not_to receive(:call_api)

      expect { subject.run }.to raise_error(SystemExit) do |error|
        expect(error.status).to eq(1)
      end
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
