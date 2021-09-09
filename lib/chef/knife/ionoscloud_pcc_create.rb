require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudPccCreate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud pcc create (options)'

      option :name,
              short: '-n NAME',
              long: '--name NAME',
              description: 'Name of the data center'

      option :description,
              short: '-D DESCRIPTION',
              long: '--description DESCRIPTION',
              description: 'Description of the data center'

      option :peers,
              long: '--peers DATACENTER_ID,LAN_ID [DATACENTER_ID,LAN_ID]',
              description: 'An array of LANs joined to this private cross connect'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Creates a Private Cross-Connect.'
        @required_options = [:ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        print "#{ui.color('Creating private cross connect...', :magenta)}"

        pcc_api = Ionoscloud::PrivateCrossConnectsApi.new(api_client)
        config[:peers] = config[:peers].split(',') if config[:peers] && config[:peers].instance_of?(String)

        if config[:peers] && config[:peers].length % 2 != 0
          ui.error('Each Lan ID should correspond to one Datacenter ID!')
          exit(1)
        end

        pcc, _, headers  = pcc_api.pccs_post_with_http_info({
          properties: {
            name: config[:name],
            description: config[:description],
          }.compact,
        })

        dot = ui.color('.', :magenta)
        api_client.wait_for { print dot; is_done? get_request_id headers }

        pcc = pcc_api.pccs_find_by_id(pcc.id)

        if config[:peers]
          lan_api = Ionoscloud::LansApi.new(api_client)

          header_list = []
          allowed_datacenters_ids = pcc.properties.connectable_datacenters.map { |datacenter| datacenter.id }
          config[:peers].each_slice(2) do |datacenter_id, lan_id|
            if !allowed_datacenters_ids.include? datacenter_id
              ui.error("Datacenter ID #{datacenter_id} is not allowed")
              exit(1)
            end
            _, _, headers = lan_api.datacenters_lans_patch_with_http_info(
              datacenter_id,
              lan_id,
              { pcc: pcc.id },
            )
            header_list << headers
          end

          header_list.each do |headers|
            dot = ui.color('.', :magenta)
            api_client.wait_for { print dot; is_done? get_request_id headers }
          end
        end

        pcc = pcc_api.pccs_find_by_id(pcc.id)

        puts "\n"
        puts "#{ui.color('ID', :cyan)}: #{pcc.id}"
        puts "#{ui.color('Name', :cyan)}: #{pcc.properties.name}"
        puts "#{ui.color('Description', :cyan)}: #{pcc.properties.description}"
        puts "#{ui.color('Peers', :cyan)}: #{pcc.properties.peers.to_s}"
        puts "#{ui.color('Datacenters', :cyan)}: #{pcc.properties.connectable_datacenters.to_s}"
        puts 'done'
      end
    end
  end
end
