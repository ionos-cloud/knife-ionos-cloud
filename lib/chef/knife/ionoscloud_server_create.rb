require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudServerCreate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud server create (options)'

      option :datacenter_id,
             short: '-D DATACENTER_ID',
             long: '--datacenter-id DATACENTER_ID',
             description: 'Name of the virtual datacenter'

      option :name,
             short: '-n NAME',
             long: '--name NAME',
             description: 'Name of the server'

      option :cores,
             short: '-C CORES',
             long: '--cores CORES',
             description: 'The number of processor cores'

      option :cpu_family,
             short: '-f CPU_FAMILY',
             long: '--cpu-family CPU_FAMILY',
             description: 'The family of the CPU (INTEL_XEON or AMD_OPTERON)',
             default: 'INTEL_SKYLAKE'

      option :ram,
             short: '-r RAM',
             long: '--ram RAM',
             description: 'The amount of RAM in MB'

      option :availability_zone,
             short: '-a AVAILABILITY_ZONE',
             long: '--availability-zone AVAILABILITY_ZONE',
             description: 'The availability zone of the server',
             default: 'AUTO'

      option :boot_volume,
             long: '--boot-volume VOLUME_ID',
             description: 'Reference to a volume used for booting'

      option :boot_cdrom,
             long: '--boot-cdrom CDROM_ID',
             description: 'Reference to a CD-ROM used for booting'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        "One of the unique features of the Ionoscloud platform when compared "\
        "with the other providers is that they allow you to define your own settings "\
        "for cores, memory, and disk size without being tied to a particular size or flavor.\n\n"\
        "Note: *The memory parameter value must be a multiple of 256, e.g. 256, 512, 768, 1024, and so forth.*"
        @required_options = [:datacenter_id, :cores, :ram, :ionoscloud_username, :ionoscloud_password]
      end

      def run
       $stdout.sync = true
       validate_required_params(@required_options, config)

        print "#{ui.color('Creating server...', :magenta)}"
        params = {
          name: config[:name],
          cores: config[:cores],
          cpuFamily: config[:cpu_family],
          ram: config[:ram],
          availabilityZone: config[:availability_zone]
        }

        params[:bootCdrom] = { id: config[:boot_cdrom] } unless config[:boot_cdrom].nil?
        params[:bootVolume] = { id: config[:boot_volume] } unless config[:boot_volume].nil?

        server_api = Ionoscloud::ServerApi.new(api_client)
        
        server, _, headers = server_api.datacenters_servers_post_with_http_info(
          config[:datacenter_id],
          { properties: params.compact },
        )

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
