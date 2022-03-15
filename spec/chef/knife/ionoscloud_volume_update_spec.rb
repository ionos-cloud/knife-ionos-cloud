require 'spec_helper'
require 'ionoscloud_volume_update'

Chef::Knife::IonoscloudVolumeUpdate.load_deps

describe Chef::Knife::IonoscloudVolumeUpdate do
  before :each do
    subject { Chef::Knife::IonoscloudVolumeUpdate.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call VolumesApi.datacenters_volumes_patch' do
      volume = volume_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        volume_id: volume.id,
        name: volume.properties.name + '_edited',
        size: volume.properties.size + 10,
        bus: 'IDE',
        cpu_hot_plug: (!volume.properties.cpu_hot_plug).to_s,
        ram_hot_plug: (!volume.properties.ram_hot_plug).to_s,
        nic_hot_plug: (!volume.properties.nic_hot_plug).to_s,
        disc_virtio_hot_plug: (!volume.properties.disc_virtio_hot_plug).to_s,
        disc_virtio_hot_unplug: (!volume.properties.disc_virtio_hot_unplug).to_s,

        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{volume.id}")
      expect(subject).to receive(:puts).with("Name: #{subject_config[:name]}")
      expect(subject).to receive(:puts).with("Size: #{subject_config[:size]}")
      expect(subject).to receive(:puts).with("Bus: #{subject_config[:bus]}")
      expect(subject).to receive(:puts).with("Image: #{volume.properties.image}")
      expect(subject).to receive(:puts).with("Type: #{volume.properties.type}")
      expect(subject).to receive(:puts).with("Licence Type: #{volume.properties.licence_type}")
      expect(subject).to receive(:puts).with("Backupunit ID: #{volume.properties.backupunit_id}")
      expect(subject).to receive(:puts).with("User Data: #{volume.properties.user_data}")
      expect(subject).to receive(:puts).with("Zone: #{volume.properties.availability_zone}")
      expect(subject).to receive(:puts).with("CPU Hot Plug: #{subject_config[:cpu_hot_plug]}")
      expect(subject).to receive(:puts).with("RAM Hot Plug: #{subject_config[:ram_hot_plug]}")
      expect(subject).to receive(:puts).with("NIC Hot Plug: #{subject_config[:nic_hot_plug]}")
      expect(subject).to receive(:puts).with("NIC Hot Unplug: #{volume.properties.nic_hot_unplug}")
      expect(subject).to receive(:puts).with("Disc Virtio Hot Plug: #{subject_config[:disc_virtio_hot_plug]}")
      expect(subject).to receive(:puts).with("Disc Virtio Hot Unplug: #{subject_config[:disc_virtio_hot_unplug]}")
      expect(subject).to receive(:puts).with("Device number: #{volume.properties.device_number}")
      expect(subject).to receive(:puts).with("PCI Slot: #{volume.properties.pci_slot}")

      volume.properties.name = subject_config[:name]
      volume.properties.size = subject_config[:size]
      volume.properties.bus = subject_config[:bus]
      volume.properties.cpu_hot_plug = subject_config[:cpu_hot_plug].to_s.downcase == 'true'
      volume.properties.ram_hot_plug = subject_config[:ram_hot_plug].to_s.downcase == 'true'
      volume.properties.nic_hot_plug = subject_config[:nic_hot_plug].to_s.downcase == 'true'
      volume.properties.disc_virtio_hot_plug = subject_config[:disc_virtio_hot_plug].to_s.downcase == 'true'
      volume.properties.disc_virtio_hot_unplug = subject_config[:disc_virtio_hot_unplug].to_s.downcase == 'true'

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'PATCH',
            path: "/datacenters/#{subject_config[:datacenter_id]}/volumes/#{subject_config[:volume_id]}",
            operation: :'VolumesApi.datacenters_volumes_patch',
            return_type: 'Volume',
            body: {
              name: subject_config[:name],
              size: subject_config[:size],
              bus: subject_config[:bus],
              cpuHotPlug: subject_config[:cpu_hot_plug].to_s.downcase == 'true',
              ramHotPlug: subject_config[:ram_hot_plug].to_s.downcase == 'true',
              nicHotPlug: subject_config[:nic_hot_plug].to_s.downcase == 'true',
              discVirtioHotPlug: subject_config[:disc_virtio_hot_plug].to_s.downcase == 'true',
              discVirtioHotUnplug: subject_config[:disc_virtio_hot_unplug].to_s.downcase == 'true',
            },
            result: volume,
          },
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/volumes/#{subject_config[:volume_id]}",
            operation: :'VolumesApi.datacenters_volumes_find_by_id',
            return_type: 'Volume',
            result: volume,
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
