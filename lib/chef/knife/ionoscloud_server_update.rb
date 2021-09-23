require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudServerUpdate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud server update (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'ID of the data center'

      option :server_id,
              short: '-S SERVER_ID',
              long: '--server-id SERVER_ID',
              description: 'The ID of the server to which the NIC is assigned'

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

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Updates information about a Ionoscloud Server.'
        @required_options = [:datacenter_id, :server_id, :ionoscloud_username, :ionoscloud_password]
        @updatable_fields = [:name, :cores, :cpu_family, :ram, :availability_zone, :boot_volume, :boot_cdrom]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        server_api = Ionoscloud::ServersApi.new(api_client)

        if @updatable_fields.map { |el| config[el] }.any?
          print "#{ui.color('Updating Server...', :magenta)}"

          _, _, headers  = server_api.datacenters_servers_patch_with_http_info(
            config[:datacenter_id],
            config[:server_id],
            Ionoscloud::ServerProperties.new(
              name: config[:name],
              cores: config[:cores],
              cpu_family: config[:cpu_family],
              ram: config[:ram],
              availability_zone: config[:availability_zone],
              boot_cdrom: config.key?(:boot_cdrom) ? { id: config[:boot_cdrom] } : nil,
              boot_volume: config.key?(:boot_volume) ? { id: config[:boot_volume] } : nil,
            ),
          )

          dot = ui.color('.', :magenta)
          api_client.wait_for { print dot; is_done? get_request_id headers }
        else
          ui.warn("Nothing to update, please set one of the attributes #{@updatable_fields}.")
        end

        print_server(server_api.datacenters_servers_find_by_id(config[:datacenter_id], config[:server_id]))
      end
    end
  end
end
