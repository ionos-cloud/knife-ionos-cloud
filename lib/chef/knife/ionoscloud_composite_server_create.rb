require 'chef/knife/ionoscloud_base'

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

      option :cpufamily,
             short: '-f CPU_FAMILY',
             long: '--cpu-family CPU_FAMILY',
             description: 'The family of processor cores (INTEL_XEON or AMD_OPTERON)',
             default: 'INTEL_SKYLAKE'

      option :ram,
             short: '-r RAM',
             long: '--ram RAM',
             description: '(required) The amount of RAM in MB'

      option :availabilityzone,
             short: '-a AVAILABILITY_ZONE',
             long: '--availability-zone AVAILABILITY_ZONE',
             description: 'The availability zone of the server',
             default: 'AUTO'

      option :volumename,
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

      option :imagealias,
             long: '--image-alias IMAGE_ALIAS',
             description: '(required) The image alias'

      option :type,
             short: '-t TYPE',
             long: '--type TYPE',
             description: '(required) The disk type (HDD or SSD)'

      option :licencetype,
             short: '-l LICENCE',
             long: '--licence-type LICENCE',
             description: 'The licence type of the volume (LINUX, WINDOWS, WINDOWS2016, UNKNOWN, OTHER)'

      option :imagepassword,
             short: '-P PASSWORD',
             long: '--image-password PASSWORD',
             description: 'The password set on the image for the "root" or "Administrator" user'

      option :volume_availability_zone,
             short: '-Z AVAILABILITY_ZONE',
             long: '--volume-availability-zone AVAILABILITY_ZONE',
             description: 'The volume availability zone of the server'

      option :sshkeys,
             short: '-K SSHKEY[,SSHKEY,...]',
             long: '--ssh-keys SSHKEY1,SSHKEY2,...',
             description: 'A list of public SSH keys to include',
             proc: proc { |sshkeys| sshkeys.split(',') }

      option :nicname,
             long: '--nic-name NAME',
             description: 'Name of the NIC'

      option :ips,
             short: '-i IP[,IP,...]',
             long: '--ips IP[,IP,...]',
             description: 'IPs assigned to the NIC',
             proc: proc { |ips| ips.split(',') }

      option :dhcp,
             short: '-h',
             long: '--dhcp',
             boolean: true | false,
             default: true,
             description: '(required) Set to false if you wish to disable DHCP'

      option :lan,
             short: '-L ID',
             long: '--lan ID',
             description: 'The LAN ID the NIC will reside on; if the LAN ID does not exist it will be created'

      option :nat,
             long: '--nat',
             description: 'Set to enable NAT on the NIC'
      
      attr_reader :description, :required_options
      
      def initialize(args=[])
        super(args)
        @description =
        'This creates a new composite server with an attached volume and NIC in a specified virtual data center.'
        @required_options = [:datacenter_id, :name, :cores, :ram, :size, :type, :dhcp, :lan]
      end

      def run
        $stdout.sync = true

        validate_required_params(@required_options, config)

        if !config[:image] && !config[:imagealias]
          ui.error("Either '--image' or '--image-alias' parameter must be provided")
          exit(1)
        end

        if !config[:sshkeys] && !config[:imagepassword]
          ui.error("Either '--image-password' or '--ssh-keys' parameter must be provided")
          exit(1)
        end

        print ui.color('Creating composite server...', :magenta).to_s
        volume_params = {
          name: config[:volumename],
          size: config[:size],
          bus: config[:bus] || 'VIRTIO',
          image: config[:image],
          type: config[:type],
          licenceType: config[:licencetype],
        }

        if config[:image]
          volume_params['image'] = config[:image]
        end

        if config[:imagealias]
          volume_params['imageAlias'] = config[:imagealias]
        end

        if config[:sshkeys]
          volume_params[:sshKeys] = config[:sshkeys]
        end

        if config[:imagepassword]
          volume_params[:imagePassword] = config[:imagepassword]
        end

        if config[:volume_availability_zone]
          volume_params[:availabilityZone] = config[:volume_availability_zone]
        end

        nic_params = {
          name: config[:nicname],
          ips: config[:ips],
          dhcp: config[:dhcp],
          lan: config[:lan],
        }

        nic_params[:nat] = config[:nat] if config[:nat]

        params = {
          name: config[:name],
          cores: config[:cores],
          cpuFamily: config[:cpufamily],
          ram: config[:ram],
          availabilityZone: config[:availabilityzone],
        }

        entities = { 
          volumes: {
             items: [{ properties: volume_params }],
          },
          nics: {
            items: [{ properties: nic_params }],
          },
        }

        server_api = Ionoscloud::ServerApi.new(api_client)

        server, _, headers = server_api.datacenters_servers_post_with_http_info(
          config[:datacenter_id], { properties: params.compact, entities: entities.compact },
        )

        dot = ui.color('.', :magenta)
        api_client.wait_for { print dot; is_done? get_request_id headers }

        puts "\n"
        puts "#{ui.color('ID', :cyan)}: #{server.id}"
        puts "#{ui.color('Name', :cyan)}: #{server.properties.name}"
        puts "#{ui.color('Cores', :cyan)}: #{server.properties.cores}"
        puts "#{ui.color('CPU Family', :cyan)}: #{server.properties.cpu_family}"
        puts "#{ui.color('Ram', :cyan)}: #{server.properties.ram}"
        puts "#{ui.color('Availability Zone', :cyan)}: #{server.properties.availability_zone}"

        puts 'done'
      end
    end
  end
end
