require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudCompositeServerCreate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud composite server create (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'Name of the virtual datacenter'

      option :name,
              short: '-n NAME',
              long: '--name NAME',
              description: '(required) Name of the server'

      option :cores,
              short: '-C CORES',
              long: '--cores CORES',
              description: '(required) The number of processor cores'

      option :cpu_family,
              short: '-f CPU_FAMILY',
              long: '--cpu-family CPU_FAMILY',
              description: 'The family of processor cores (INTEL_XEON or AMD_OPTERON)',
              default: 'INTEL_SKYLAKE'

      option :ram,
              short: '-r RAM',
              long: '--ram RAM',
              description: '(required) The amount of RAM in MB'

      option :availability_zone,
              short: '-a AVAILABILITY_ZONE',
              long: '--availability-zone AVAILABILITY_ZONE',
              description: 'The availability zone of the server',
              default: 'AUTO'

      option :volume_name,
              long: '--volume-name NAME',
              description: 'Name of the volume'

      option :size,
              short: '-S SIZE',
              long: '--size SIZE',
              description: '(required) The size of the volume in GB'

      option :bus,
              short: '-b BUS',
              long: '--bus BUS',
              description: 'The bus type of the volume (VIRTIO or IDE)'

      option :image,
              short: '-N ID',
              long: '--image ID',
              description: '(required) The image or snapshot ID'

      option :image_alias,
              long: '--image-alias IMAGE_ALIAS',
              description: '(required) The image alias'

      option :type,
              short: '-t TYPE',
              long: '--type TYPE',
              description: '(required) The disk type (HDD or SSD)'

      option :licence_type,
              short: '-l LICENCE',
              long: '--licence-type LICENCE',
              description: 'The licence type of the volume (LINUX, WINDOWS, WINDOWS2016, UNKNOWN, OTHER)'

      option :image_password,
              short: '-P PASSWORD',
              long: '--image-password PASSWORD',
              description: 'The password set on the image for the "root" or "Administrator" user'

      option :volume_availability_zone,
              short: '-Z AVAILABILITY_ZONE',
              long: '--volume-availability-zone AVAILABILITY_ZONE',
              description: 'The volume availability zone of the server'

      option :ssh_keys,
              short: '-K SSHKEY[,SSHKEY,...]',
              long: '--ssh-keys SSHKEY1,SSHKEY2,...',
              description: 'A list of public SSH keys to include'

      option :nic_name,
              long: '--nic-name NAME',
              description: 'Name of the NIC'

      option :ips,
              short: '-i IP[,IP,...]',
              long: '--ips IP[,IP,...]',
              description: 'IPs assigned to the NIC'

      option :dhcp,
              short: '-h',
              long: '--dhcp',
              boolean: true | false,
              default: true,
              description: 'Set to false if you wish to disable DHCP'

      option :lan,
              short: '-L ID',
              long: '--lan ID',
              description: 'The LAN ID the NIC will reside on; if the LAN ID does not exist it will be created'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'This creates a new composite server with an attached volume and NIC in a specified virtual data center.'
        @required_options = [
          :datacenter_id, :name, :cores, :ram, :size, :type, :dhcp, :lan, :ionoscloud_username, :ionoscloud_password,
        ]
      end

      def run
        $stdout.sync = true
        validate_required_params(@required_options, config)

        if !(!!config[:image] ^ !!config[:licence_type])
          ui.error('Either \'--image\' or \'--licence_type\' parameter must be provided (not both)')
          exit(1)
        end

        if config[:image]
          if !config[:ssh_keys] && !config[:image_password]
            ui.error('Either \'--image-password\' or \'--ssh-keys\' parameter must be provided when image is set')
            exit(1)
          end

          if config[:ssh_keys]
            config[:ssh_keys] = config[:ssh_keys].split(',')
          end
        else
          if config[:ssh_keys] || config[:image_password]
            ui.error('Neither \'--image-password\' nor \'--ssh-keys\' parameters should be provided when image is not set')
            exit(1)
          end
        end


        if config[:ips]
          config[:ips] = config[:ips].split(',')
        end

        print ui.color('Creating composite server...', :magenta).to_s

        volume = Ionoscloud::Volume.new(
          properties: Ionoscloud::VolumeProperties.new({
            name: config[:volume_name],
            size: config[:size],
            bus: config[:bus] || 'VIRTIO',
            image: config[:image],
            image_alias: config[:image_alias],
            ssh_keys: config[:ssh_keys],
            image_password: config[:image_password],
            type: config[:type],
            licence_type: config[:licence_type],
            availability_zone: config[:volume_availability_zone],
          }.compact)
        )

        nic = Ionoscloud::Nic.new(
          properties: Ionoscloud::NicProperties.new({
            name: config[:nic_name],
            ips: config[:ips],
            dhcp: config[:dhcp],
            lan: config[:lan],
          }.compact)
        )

        server = Ionoscloud::Server.new(
          properties: Ionoscloud::ServerProperties.new({
            name: config[:name],
            cores: config[:cores],
            cpu_family: config[:cpu_family],
            ram: config[:ram],
            availability_zone: config[:availability_zone],
          }.compact),
          entities: Ionoscloud::ServerEntities.new(
            volumes: {
               items: [volume],
            },
            nics: {
              items: [nic],
            },
          ),
        )

        server_api = Ionoscloud::ServersApi.new(api_client)

        server, _, headers = server_api.datacenters_servers_post_with_http_info(config[:datacenter_id], server)

        dot = ui.color('.', :magenta)
        api_client.wait_for { print dot; is_done? get_request_id headers }

        server = server_api.datacenters_servers_find_by_id(config[:datacenter_id], server.id)

        puts "\n"
        puts "#{ui.color('ID', :cyan)}: #{server.id}"
        puts "#{ui.color('Name', :cyan)}: #{server.properties.name}"
        puts "#{ui.color('Cores', :cyan)}: #{server.properties.cores}"
        puts "#{ui.color('CPU Family', :cyan)}: #{server.properties.cpu_family}"
        puts "#{ui.color('Ram', :cyan)}: #{server.properties.ram}"
        puts "#{ui.color('Availability Zone', :cyan)}: #{server.properties.availability_zone}"
        puts "#{ui.color('Boot Volume', :cyan)}: #{server.properties.boot_volume ? server.properties.boot_volume.id : ''}"
        puts "#{ui.color('Boot CDROM', :cyan)}: #{server.properties.boot_cdrom ? server.properties.boot_cdrom.id : ''}"

        puts 'done'
      end
    end
  end
end
