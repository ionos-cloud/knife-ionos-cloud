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
              description: 'The family of the CPU (INTEL_XEON or AMD_OPTERON)'

      option :ram,
              short: '-r RAM',
              long: '--ram RAM',
              description: 'The amount of RAM in MB'

      option :availability_zone,
              short: '-a AVAILABILITY_ZONE',
              long: '--availability-zone AVAILABILITY_ZONE',
              description: 'The availability zone of the server'

      option :boot_volume,
              long: '--boot-volume VOLUME_ID',
              description: 'Reference to a volume used for booting'

      option :boot_cdrom,
              long: '--boot-cdrom CDROM_ID',
              description: 'Reference to a CD-ROM used for booting'

      def initialize(args = [])
        super(args)
        @description =
        'One of the unique features of the Ionoscloud platform when compared '\
        'with the other providers is that they allow you to define your own settings '\
        "for cores, memory, and disk size without being tied to a particular size or flavor.\n\n"\
        'Note: _The memory parameter value must be a multiple of 256, e.g. 256, 512, 768, 1024, and so forth._'
        @directory = 'compute-engine'
        @required_options = [:datacenter_id, :cores, :ram]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        print "#{ui.color('Creating server...', :magenta)}"

        servers_api = Ionoscloud::ServersApi.new(api_client)

        server, _, headers = servers_api.datacenters_servers_post_with_http_info(
          config[:datacenter_id],
          Ionoscloud::Server.new(
            properties: Ionoscloud::ServerProperties.new(
              name: config[:name],
              cores: config[:cores],
              cpu_family: config[:cpu_family],
              ram: config[:ram],
              availability_zone: config[:availability_zone],
              boot_cdrom: config.key?(:boot_cdrom) ? { id: config[:boot_cdrom] } : nil,
              boot_volume: config.key?(:boot_volume) ? { id: config[:boot_volume] } : nil,
            ),
          ),
        )

        dot = ui.color('.', :magenta)
        api_client.wait_for { print dot; is_done? get_request_id headers }

        print_server(servers_api.datacenters_servers_find_by_id(config[:datacenter_id], server.id))
      end
    end
  end
end
