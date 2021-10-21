require 'spec_helper'
require 'ionoscloud_snapshot_get'

Chef::Knife::IonoscloudSnapshotGet.load_deps

describe Chef::Knife::IonoscloudSnapshotGet do
  before :each do
    subject { Chef::Knife::IonoscloudSnapshotGet.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call SnapshotsApi.snapshots_find_by_id' do
      snapshot = snapshot_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        snapshot_id: snapshot.id,
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{snapshot.id}")
      expect(subject).to receive(:puts).with("Name: #{snapshot.properties.name}")
      expect(subject).to receive(:puts).with("Description: #{snapshot.properties.description}")
      expect(subject).to receive(:puts).with("Location: #{snapshot.properties.location}")
      expect(subject).to receive(:puts).with("Size: #{snapshot.properties.size.to_s}")
      expect(subject).to receive(:puts).with("Sec Auth Protection: #{snapshot.properties.sec_auth_protection}")
      expect(subject).to receive(:puts).with("License Type: #{snapshot.properties.licence_type}")
      expect(subject).to receive(:puts).with("CPU Hot Plug: #{snapshot.properties.cpu_hot_plug}")
      expect(subject).to receive(:puts).with("CPU Hot Unplug: #{snapshot.properties.cpu_hot_unplug}")
      expect(subject).to receive(:puts).with("RAM Hot Plug: #{snapshot.properties.ram_hot_plug}")
      expect(subject).to receive(:puts).with("RAM Hot Unplug: #{snapshot.properties.ram_hot_unplug}")
      expect(subject).to receive(:puts).with("NIC Hot Plug: #{snapshot.properties.nic_hot_plug}")
      expect(subject).to receive(:puts).with("NIC Hot Unplug: #{snapshot.properties.nic_hot_unplug}")
      expect(subject).to receive(:puts).with("Disc Virtio Hot Plug: #{snapshot.properties.disc_virtio_hot_plug}")
      expect(subject).to receive(:puts).with("Disc Virtio Hot Unplug: #{snapshot.properties.disc_virtio_hot_unplug}")
      expect(subject).to receive(:puts).with("Disc Scsi Hot Plug: #{snapshot.properties.disc_scsi_hot_plug}")
      expect(subject).to receive(:puts).with("Disc Scsi Hot Unplug: #{snapshot.properties.disc_scsi_hot_unplug}")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
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
