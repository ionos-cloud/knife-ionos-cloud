require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudVolumeUpdate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud volume update (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'Name of the data center'

      option :volume_id,
              long: '--volume VOLUME_ID',
              description: 'ID of the Volume.'

      option :name,
              short: '-n NAME',
              long: '--name NAME',
              description: 'Name of the volume'

      option :size,
              short: '-S SIZE',
              long: '--size SIZE',
              description: 'The size of the volume in GB'

      option :bus,
              short: '-b BUS',
              long: '--bus BUS',
              description: 'The bus type of the volume (VIRTIO or IDE)'

      option :cpu_hot_plug,
              long: '--cpu-hot-plug CPU_HOT_PLUG',
              description: 'The licence type of the volume (LINUX, WINDOWS, UNKNOWN, OTHER)'

      option :ram_hot_plug,
              long: '--ram-hot-plug RAM_HOT_PLUG',
              description: 'The licence type of the volume (LINUX, WINDOWS, UNKNOWN, OTHER)'

      option :nic_hot_plug,
              long: '--nic-hot-plug NIC_HOT_PLUG',
              description: 'The licence type of the volume (LINUX, WINDOWS, UNKNOWN, OTHER)'

      option :nic_hot_unplug,
              long: '--nic-hot-unplug NIC_HOT_UNPLUG',
              description: 'The licence type of the volume (LINUX, WINDOWS, UNKNOWN, OTHER)'

      option :disc_virtio_hot_plug,
              long: '--disc-virtio-hot_plug DISC_VIRTIO_HOT_PLUG',
              description: 'The licence type of the volume (LINUX, WINDOWS, UNKNOWN, OTHER)'

      option :disc_virtio_hot_unplug,
              long: '--disc-virtio-hot_unplug DISC_VIRTIO_HOT_UNPLUG',
              description: 'The licence type of the volume (LINUX, WINDOWS, UNKNOWN, OTHER)'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Updates information about a Ionoscloud Volume.'
        @required_options = [:datacenter_id, :volume_id, :ionoscloud_username, :ionoscloud_password]
        @updatable_fields = [
          :name, :size, :bus, :cpu_hot_plug, :ram_hot_plug, :nic_hot_plug, :nic_hot_unplug, :disc_virtio_hot_plug, :disc_virtio_hot_unplug,
        ]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        volume = Ionoscloud::VolumeApi.new(api_client)

        if @updatable_fields.map { |el| config[el] }.any?
          print "#{ui.color('Updating Volume...', :magenta)}"

          _, _, headers  = volume.datacenters_volumes_patch_with_http_info(
            config[:datacenter_id],
            config[:volume_id],
            Ionoscloud::VolumeProperties.new(
              name: config[:name],
              size: config[:size],
              bus: config[:bus],
              cpu_hot_plug: (config.key?(:cpu_hot_plug) ? config[:cpu_hot_plug].to_s.downcase == 'true' : nil),
              ram_hot_plug: (config.key?(:ram_hot_plug) ? config[:ram_hot_plug].to_s.downcase == 'true' : nil),
              nic_hot_plug: (config.key?(:nic_hot_plug) ? config[:nic_hot_plug].to_s.downcase == 'true' : nil),
              nic_hot_unplug: (config.key?(:nic_hot_unplug) ? config[:nic_hot_unplug].to_s.downcase == 'true' : nil),
              disc_virtio_hot_plug: (config.key?(:disc_virtio_hot_plug) ? config[:disc_virtio_hot_plug].to_s.downcase == 'true' : nil),
              disc_virtio_hot_unplug: (config.key?(:disc_virtio_hot_unplug) ? config[:disc_virtio_hot_unplug].to_s.downcase == 'true' : nil),
            ),
          )

          dot = ui.color('.', :magenta)
          api_client.wait_for { print dot; is_done? get_request_id headers }
        else
          ui.warn("Nothing to update, please set one of the attributes #{@updatable_fields}.")
        end

        print_volume(volume.datacenters_volumes_find_by_id(config[:datacenter_id], config[:volume_id]))
      end
    end
  end
end
