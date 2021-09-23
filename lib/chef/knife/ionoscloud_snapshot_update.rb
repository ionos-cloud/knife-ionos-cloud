require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudSnapshotUpdate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud snapshot update (options)'

      option :snapshot_id,
              short: '-S SNAPSHOT_ID',
              long: '--snapshot-id SNAPSHOT_ID',
              description: 'ID of the Snapshot.'

      option :name,
              short: '-n NAME',
              long: '--name NAME',
              description: 'Name of the server'

      option :description,
              long: '--description DESCRIPTION',
              description: 'The number of processor cores'

      option :sec_auth_protection,
              long: '--sec-auth-protection SEC_AUTH_PROTECTION',
              description: 'Boolean value representing if the snapshot requires extra protection e.g. two factor protection'

      option :licence_type,
              short: '-l LICENCE',
              long: '--licence-type LICENCE',
              description: 'The licence type of the snapshot (LINUX, WINDOWS, UNKNOWN, OTHER)'

      option :cpu_hot_plug,
              long: '--cpu-hot-plug CPU_HOT_PLUG',
              description: 'The licence type of the snapshot (LINUX, WINDOWS, UNKNOWN, OTHER)'

      option :cpu_hot_unplug,
              long: '--cpu-hot-unplug CPU_HOT_UNPLUG',
              description: 'The licence type of the snapshot (LINUX, WINDOWS, UNKNOWN, OTHER)'

      option :ram_hot_plug,
              long: '--ram-hot-plug RAM_HOT_PLUG',
              description: 'The licence type of the snapshot (LINUX, WINDOWS, UNKNOWN, OTHER)'

      option :ram_hot_unplug,
              long: '--ram-hot-unplug RAM_HOT_UNPLUG',
              description: 'The licence type of the snapshot (LINUX, WINDOWS, UNKNOWN, OTHER)'

      option :nic_hot_plug,
              long: '--nic-hot-plug NIC_HOT_PLUG',
              description: 'The licence type of the snapshot (LINUX, WINDOWS, UNKNOWN, OTHER)'

      option :nic_hot_unplug,
              long: '--nic-hot-unplug NIC_HOT_UNPLUG',
              description: 'The licence type of the snapshot (LINUX, WINDOWS, UNKNOWN, OTHER)'

      option :disc_virtio_hot_plug,
              long: '--disc-virtio-hot_plug DISC_VIRTIO_HOT_PLUG',
              description: 'The licence type of the snapshot (LINUX, WINDOWS, UNKNOWN, OTHER)'

      option :disc_virtio_hot_unplug,
              long: '--disc-virtio-hot_unplug DISC_VIRTIO_HOT_UNPLUG',
              description: 'The licence type of the snapshot (LINUX, WINDOWS, UNKNOWN, OTHER)'

      option :disc_scsi_hot_plug,
              long: '--disc-scsi-hot-plug DISC_SCSI_HOT_PLUG',
              description: 'The licence type of the snapshot (LINUX, WINDOWS, UNKNOWN, OTHER)'

      option :disc_scsi_hot_unplug,
              long: '--disc-scsi-hot-unplug DISC_SCSI_HOT_UNPLUG',
              description: 'The licence type of the snapshot (LINUX, WINDOWS, UNKNOWN, OTHER)'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Updates information about a Ionoscloud Snapshot.'
        @required_options = [:snapshot_id, :ionoscloud_username, :ionoscloud_password]
        @updatable_fields = [
          :name, :description, :sec_auth_protection, :licence_type, :cpu_hot_plug, :cpu_hot_unplug, :ram_hot_plug, :ram_hot_unplug,
          :nic_hot_plug, :nic_hot_unplug, :disc_virtio_hot_plug, :disc_virtio_hot_unplug, :disc_scsi_hot_plug, :disc_scsi_hot_unplug,
        ]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        server_api = Ionoscloud::SnapshotsApi.new(api_client)

        if @updatable_fields.map { |el| config[el] }.any?
          print "#{ui.color('Updating Snapshot...', :magenta)}"

          _, _, headers  = server_api.snapshots_patch_with_http_info(
            config[:snapshot_id],
            Ionoscloud::SnapshotProperties.new(
              name: config[:name],
              description: config[:description],
              sec_auth_protection: (config.key?(:sec_auth_protection) ? config[:sec_auth_protection].to_s.downcase == 'true' : nil),
              licence_type: config[:licence_type],
              cpu_hot_plug: (config.key?(:cpu_hot_plug) ? config[:cpu_hot_plug].to_s.downcase == 'true' : nil),
              cpu_hot_unplug: (config.key?(:cpu_hot_unplug) ? config[:cpu_hot_unplug].to_s.downcase == 'true' : nil),
              ram_hot_plug: (config.key?(:ram_hot_plug) ? config[:ram_hot_plug].to_s.downcase == 'true' : nil),
              ram_hot_unplug: (config.key?(:ram_hot_unplug) ? config[:ram_hot_unplug].to_s.downcase == 'true' : nil),
              nic_hot_plug: (config.key?(:nic_hot_plug) ? config[:nic_hot_plug].to_s.downcase == 'true' : nil),
              nic_hot_unplug: (config.key?(:nic_hot_unplug) ? config[:nic_hot_unplug].to_s.downcase == 'true' : nil),
              disc_virtio_hot_plug: (config.key?(:disc_virtio_hot_plug) ? config[:disc_virtio_hot_plug].to_s.downcase == 'true' : nil),
              disc_virtio_hot_unplug: (config.key?(:disc_virtio_hot_unplug) ? config[:disc_virtio_hot_unplug].to_s.downcase == 'true' : nil),
              disc_scsi_hot_plug: (config.key?(:disc_scsi_hot_plug) ? config[:disc_scsi_hot_plug].to_s.downcase == 'true' : nil),
              disc_scsi_hot_unplug: (config.key?(:disc_scsi_hot_unplug) ? config[:disc_scsi_hot_unplug].to_s.downcase == 'true' : nil),
            ),
          )

          dot = ui.color('.', :magenta)
          api_client.wait_for { print dot; is_done? get_request_id headers }
        else
          ui.warn("Nothing to update, please set one of the attributes #{@updatable_fields}.")
        end

        print_snapshot(server_api.snapshots_find_by_id(config[:snapshot_id]))
      end
    end
  end
end
