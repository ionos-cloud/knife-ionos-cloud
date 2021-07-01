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
              description: 'The bus type of the volume (VIRTIO or IDE)'

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
        validate_required_params(@required_options, config)

        if !config[:image] && !config[:image_alias]
          ui.error('Either \'--image\' or \'--image-alias\' parameter must be provided')
          exit(1)
        end

        if !config[:ssh_keys] && !config[:image_password]
          ui.error('Either \'--image-password\' or \'--ssh-keys\' parameter must be provided')
          exit(1)
        end

        if config[:ssh_keys]
          config[:ssh_keys] = config[:ssh_keys].split(',')
        end

        print "#{ui.color('Creating volume...', :magenta)}"

        volume_api = Ionoscloud::VolumeApi.new(api_client)

        volume, _, headers = volume_api.datacenters_volumes_post_with_http_info(
          config[:datacenter_id],
          {
            properties: {
              name: config[:name],
              size: config[:size],
              bus: config[:bus] || 'VIRTIO',
              type: config[:type],
              licenceType: config[:licence_type],
              image: config[:image],
              imageAlias: config[:image_alias],
              sshKeys: config[:sshKeys],
              imagePassword: config[:image_password],
              availabilityZone: config[:availability_zone],
              backupunit_id: config[:backupunit_id],
              user_data: config[:user_data],
            }.compact
          },
        )

        dot = ui.color('.', :magenta)
        api_client.wait_for(300) { print dot; is_done? get_request_id headers }

        volume = volume_api.datacenters_volumes_find_by_id(config[:datacenter_id], volume.id)

        puts "\n"
        puts "#{ui.color('ID', :cyan)}: #{volume.id}"
        puts "#{ui.color('Name', :cyan)}: #{volume.properties.name}"
        puts "#{ui.color('Size', :cyan)}: #{volume.properties.size}"
        puts "#{ui.color('Bus', :cyan)}: #{volume.properties.bus}"
        puts "#{ui.color('Image', :cyan)}: #{volume.properties.image}"
        puts "#{ui.color('Type', :cyan)}: #{volume.properties.type}"
        puts "#{ui.color('Licence Type', :cyan)}: #{volume.properties.licence_type}"
        puts "#{ui.color('Zone', :cyan)}: #{volume.properties.availability_zone}"
        puts 'done'
      end
    end
  end
end
