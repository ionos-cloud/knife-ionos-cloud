require 'spec_helper'
require 'ionoscloud_snapshot_update'

Chef::Knife::IonoscloudSnapshotUpdate.load_deps

describe Chef::Knife::IonoscloudSnapshotUpdate do
  before :each do
    subject { Chef::Knife::IonoscloudSnapshotUpdate.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call SnapshotsApi.datacenters_snapshots_patch' do
      snapshot = snapshot_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        snapshot_id: snapshot.id,
        name: snapshot.properties.name + '_edited',
        description: snapshot.properties.description + '_edited',
        licence_type: 'WINDOWS',
        cpu_hot_plug: (!snapshot.properties.cpu_hot_plug).to_s,
        ram_hot_plug: (!snapshot.properties.ram_hot_plug).to_s,
        disc_virtio_hot_plug: (!snapshot.properties.disc_virtio_hot_plug).to_s,
        disc_virtio_hot_unplug: (!snapshot.properties.disc_virtio_hot_unplug).to_s,
        disc_scsi_hot_plug: (!snapshot.properties.disc_scsi_hot_plug).to_s,
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{snapshot.id}")
      expect(subject).to receive(:puts).with("Name: #{subject_config[:name]}")
      expect(subject).to receive(:puts).with("Description: #{subject_config[:description]}")
      expect(subject).to receive(:puts).with("Location: #{snapshot.properties.location}")
      expect(subject).to receive(:puts).with("Size: #{snapshot.properties.size.to_s}")
      expect(subject).to receive(:puts).with("Sec Auth Protection: #{snapshot.properties.sec_auth_protection}")
      expect(subject).to receive(:puts).with("License Type: #{subject_config[:licence_type]}")
      expect(subject).to receive(:puts).with("CPU Hot Plug: #{subject_config[:cpu_hot_plug]}")
      expect(subject).to receive(:puts).with("CPU Hot Unplug: #{snapshot.properties.cpu_hot_unplug}")
      expect(subject).to receive(:puts).with("RAM Hot Plug: #{subject_config[:ram_hot_plug]}")
      expect(subject).to receive(:puts).with("RAM Hot Unplug: #{snapshot.properties.ram_hot_unplug}")
      expect(subject).to receive(:puts).with("NIC Hot Plug: #{snapshot.properties.nic_hot_plug}")
      expect(subject).to receive(:puts).with("NIC Hot Unplug: #{snapshot.properties.nic_hot_unplug}")
      expect(subject).to receive(:puts).with("Disc Virtio Hot Plug: #{subject_config[:disc_virtio_hot_plug]}")
      expect(subject).to receive(:puts).with("Disc Virtio Hot Unplug: #{subject_config[:disc_virtio_hot_unplug]}")
      expect(subject).to receive(:puts).with("Disc Scsi Hot Plug: #{subject_config[:disc_scsi_hot_plug]}")
      expect(subject).to receive(:puts).with("Disc Scsi Hot Unplug: #{snapshot.properties.disc_scsi_hot_unplug}")

      snapshot.properties.name = subject_config[:name]
      snapshot.properties.description = subject_config[:description]
      snapshot.properties.licence_type = subject_config[:licence_type]
      snapshot.properties.cpu_hot_plug = subject_config[:cpu_hot_plug].to_s.downcase == 'true'
      snapshot.properties.ram_hot_plug = subject_config[:ram_hot_plug].to_s.downcase == 'true'
      snapshot.properties.disc_virtio_hot_plug = subject_config[:disc_virtio_hot_plug].to_s.downcase == 'true'
      snapshot.properties.disc_virtio_hot_unplug = subject_config[:disc_virtio_hot_unplug].to_s.downcase == 'true'
      snapshot.properties.disc_scsi_hot_plug = subject_config[:disc_scsi_hot_plug].to_s.downcase == 'true'

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'PATCH',
            path: "/snapshots/#{subject_config[:snapshot_id]}",
            operation: :'SnapshotsApi.snapshots_patch',
            return_type: 'Snapshot',
            body: {
              name: subject_config[:name],
              description: subject_config[:description],
              licenceType: subject_config[:licence_type],
              cpuHotPlug: subject_config[:cpu_hot_plug].to_s.downcase == 'true',
              ramHotPlug: subject_config[:ram_hot_plug].to_s.downcase == 'true',
              discVirtioHotPlug: subject_config[:disc_virtio_hot_plug].to_s.downcase == 'true',
              discVirtioHotUnplug: subject_config[:disc_virtio_hot_unplug].to_s.downcase == 'true',
              discScsiHotPlug: subject_config[:disc_scsi_hot_plug].to_s.downcase == 'true',
            },
            result: snapshot,
          },
          {
            method: 'GET',
            path: "/snapshots/#{subject_config[:snapshot_id]}",
            operation: :'SnapshotsApi.snapshots_find_by_id',
            return_type: 'Snapshot',
            result: snapshot,
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
