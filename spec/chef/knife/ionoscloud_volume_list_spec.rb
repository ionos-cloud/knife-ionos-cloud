require 'spec_helper'
require 'ionoscloud_volume_list'

Chef::Knife::IonoscloudVolumeList.load_deps

describe Chef::Knife::IonoscloudVolumeList do
  before :each do
    subject { Chef::Knife::IonoscloudVolumeList.new }

    @volumes = volumes_mock

    @volume_list = volume_list = [
      subject.ui.color('ID', :bold),
      subject.ui.color('Name', :bold),
      subject.ui.color('Size', :bold),
      subject.ui.color('Bus', :bold),
      subject.ui.color('Image', :bold),
      subject.ui.color('Type', :bold),
      subject.ui.color('Zone', :bold),
      subject.ui.color('Device Number', :bold),
      @volumes.items.first.id,
      @volumes.items.first.properties.name,
      @volumes.items.first.properties.size.to_s,
      @volumes.items.first.properties.bus,
      @volumes.items.first.properties.image,
      @volumes.items.first.properties.type,
      @volumes.items.first.properties.availability_zone,
      @volumes.items.first.properties.device_number.to_s,
      @volumes.items[1].id,
      @volumes.items[1].properties.name,
      @volumes.items[1].properties.size.to_s,
      @volumes.items[1].properties.bus,
      @volumes.items[1].properties.image,
      @volumes.items[1].properties.type,
      @volumes.items[1].properties.availability_zone,
      @volumes.items[1].properties.device_number.to_s,
    ]

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call VolumeApi.datacenters_volumes_get when no server_id is set' do
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject.ui).to receive(:list).with(@volume_list, :uneven_columns_across, 8)

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/volumes",
            operation: :'VolumeApi.datacenters_volumes_get',
            return_type: 'Volumes',
            result: @volumes,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should call ServerApi.datacenters_servers_volumes_get when server_id is set' do
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        server_id: 'server_id'
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject.ui).to receive(:list).with(@volume_list, :uneven_columns_across, 8)

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers/#{subject_config[:server_id]}/volumes",
            operation: :'ServerApi.datacenters_servers_volumes_get',
            return_type: 'AttachedVolumes',
            result: @volumes,
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
