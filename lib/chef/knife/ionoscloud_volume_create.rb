require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudVolumeCreate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud volume create (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'Name of the data center'

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
              description: 'The bus type of the volume (VIRTIO or IDE)',
              default: 'VIRTIO'

      option :image,
              short: '-N ID',
              long: '--image ID',
              description: 'The image or snapshot ID'

      option :image_alias,
              long: '--image-alias IMAGE_ALIAS',
              description: '(required) The image alias'

      option :image_password,
              short: '-P PASSWORD',
              long: '--image-password PASSWORD',
              description: 'The password set on the image for the "root" or "Administrator" user'

      option :type,
              short: '-t TYPE',
              long: '--type TYPE',
              description: 'The disk type (HDD OR SSD)'

      option :licence_type,
              short: '-l LICENCE',
              long: '--licence-type LICENCE',
              description: 'The licence type of the volume (LINUX, WINDOWS, UNKNOWN, OTHER)'

      option :ssh_keys,
              short: '-K SSHKEY[,SSHKEY,...]',
              long: '--ssh-keys SSHKEY1,SSHKEY2,...',
              description: 'A list of public SSH keys to include'

      option :availability_zone,
              short: '-Z AVAILABILITY_ZONE',
              long: '--availability-zone AVAILABILITY_ZONE',
              description: 'The volume availability zone of the server'

      option :backupunit_id,
              short: '-B BACKUPUNIT_ID',
              long: '--backupunit BACKUPUNIT_ID',
              description: 'The uuid of the Backup Unit that user has access to. The property is immutable and is only allowed '\
              'to be set on a new volume creation. It is mandatory to provide either \'public image\' or \'imageAlias\' in '\
              'conjunction with this property.'

      option :user_data,
              short: '-u USER_DATA',
              long: '--user-data USER_DATA',
              description: 'The cloud-init configuration for the volume as base64 encoded string. The property is '\
              'immutable and is only allowed to be set on a new volume creation. It is mandatory to provide either \'public image\' '\
              'or \'imageAlias\' that has cloud-init compatibility in conjunction with this property.'

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
        'Creates a volume within the data center. This will NOT attach the volume to a server. '\
        'Please see the Servers section for details on how to attach storage volumes.'
        @required_options = [:datacenter_id, :name, :type, :size, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        config[:ssh_keys] = config[:ssh_keys].split(',') if config[:ssh_keys] && config[:ssh_keys].instance_of?(String)

        print "#{ui.color('Creating volume...', :magenta)}"

        volume_api = Ionoscloud::VolumeApi.new(api_client)

        volume, _, headers = volume_api.datacenters_volumes_post_with_http_info(
          config[:datacenter_id],
          Ionoscloud::Volume.new(
            properties: Ionoscloud::VolumeProperties.new(
              name: config[:name],
              size: config[:size],
              bus: config[:bus],
              type: config[:type],
              licence_type: config[:licence_type],
              image: config[:image],
              image_alias: config[:image_alias],
              ssh_keys: config[:ssh_keys],
              image_password: config[:image_password],
              availability_zone: config[:availability_zone],
              backupunit_id: config[:backupunit_id],
              user_data: config[:user_data],
              cpu_hot_plug: (config.key?(:cpu_hot_plug) ? config[:cpu_hot_plug].to_s.downcase == 'true' : nil),
              ram_hot_plug: (config.key?(:ram_hot_plug) ? config[:ram_hot_plug].to_s.downcase == 'true' : nil),
              nic_hot_plug: (config.key?(:nic_hot_plug) ? config[:nic_hot_plug].to_s.downcase == 'true' : nil),
              nic_hot_unplug: (config.key?(:nic_hot_unplug) ? config[:nic_hot_unplug].to_s.downcase == 'true' : nil),
              disc_virtio_hot_plug: (config.key?(:disc_virtio_hot_plug) ? config[:disc_virtio_hot_plug].to_s.downcase == 'true' : nil),
              disc_virtio_hot_unplug: (config.key?(:disc_virtio_hot_unplug) ? config[:disc_virtio_hot_unplug].to_s.downcase == 'true' : nil),
            ),
          ),
        )

        dot = ui.color('.', :magenta)
        api_client.wait_for(300) { print dot; is_done? get_request_id headers }

        print_volume(volume_api.datacenters_volumes_find_by_id(config[:datacenter_id], volume.id))
      end
    end
  end
end
