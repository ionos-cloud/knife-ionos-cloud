require 'chef/knife/profitbricks_base'

class Chef
  class Knife
    class ProfitbricksServerCreate < Knife
      include Knife::ProfitbricksBase

      banner 'knife profitbricks server create (options)'

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

      option :cpufamily,
             short: '-f CPU_FAMILY',
             long: '--cpu-family CPU_FAMILY',
             description: 'The family of the CPU (INTEL_XEON or AMD_OPTERON)',
             default: 'INTEL_SKYLAKE'

      option :ram,
             short: '-r RAM',
             long: '--ram RAM',
             description: 'The amount of RAM in MB'

      option :availabilityzone,
             short: '-a AVAILABILITY_ZONE',
             long: '--availability-zone AVAILABILITY_ZONE',
             description: 'The availability zone of the server',
             default: 'AUTO'

      option :bootvolume,
             long: '--boot-volume VOLUME_ID',
             description: 'Reference to a volume used for booting'

      option :bootcdrom,
             long: '--boot-cdrom CDROM_ID',
             description: 'Reference to a CD-ROM used for booting'

      def run
        $stdout.sync = true
        validate_required_params(%i(datacenter_id name cores ram), config)

        print "#{ui.color('Creating server...', :magenta)}"
        params = {
          name: config[:name],
          cores: config[:cores],
          cpuFamily: config[:cpufamily],
          ram: config[:ram],
          availabilityZone: config[:availabilityzone]
        }

        if config[:bootcdrom]
          params[:bootCdrom] = { id: config[:bootcdrom] }
        end

        if config[:bootvolume]
          params[:bootVolume] = { id: config[:bootvolume] }
        end

        server_api = Ionoscloud::ServerApi.new(api_client)
        
        server, _, headers = server_api.datacenters_servers_post_with_http_info(
          config[:datacenter_id],
          { 'properties' => params.compact },
        )

        request_id = headers['Location'].scan(%r{/requests/(\b[0-9a-f]{8}\b-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-\b[0-9a-f]{12}\b)}).last.first

        dot = ui.color('.', :magenta)
        api_client.wait_for { print dot; is_done? request_id }

        server = server_api.datacenters_servers_find_by_id(config[:datacenter_id], server.id)

        puts "\n"
        puts "#{ui.color('ID', :cyan)}: #{server.id}"
        puts "#{ui.color('Name', :cyan)}: #{server.properties.name}"
        puts "#{ui.color('Cores', :cyan)}: #{server.properties.cores}"
        puts "#{ui.color('CPU Family', :cyan)}: #{server.properties.cpu_family}"
        puts "#{ui.color('Ram', :cyan)}: #{server.properties.ram}"
        puts "#{ui.color('Availability Zone', :cyan)}: #{server.properties.availability_zone}"
        puts "#{ui.color('Boot Volume', :cyan)}: #{server.properties.boot_volume}"
        puts "#{ui.color('Boot CDROM', :cyan)}: #{server.properties.boot_cdrom}"

        puts 'done'
      end
    end
  end
end
