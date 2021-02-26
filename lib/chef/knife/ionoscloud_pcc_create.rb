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
              long: '--peers LAN_ID [LAN_ID]',
              description: 'An array of LANs joined to this private cross connect'

      option :datacenters,
              long: '--datacenters DATACENTER_IS [DATACENTER_IS]',
              description: 'An array of datacenters joined to this private cross connect'
      
      attr_reader :description, :required_options
      
      def initialize(args = [])
        super(args)
        @description =
        'Creates a Private Cross-Connect.'
        @required_options = [:ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        validate_required_params(@required_options, config)

        print "#{ui.color('Creating private cross connect...', :magenta)}"

        pcc_api = Ionoscloud::PrivateCrossConnectApi.new(api_client)

        config[:peers] = config[:peers].split(',').map { |peer| { id: peer } } unless config[:peers].nil?
        config[:datacenters] = config[:datacenters].split(',').map { |datacenter| { id: datacenter } } unless config[:datacenters].nil?

        pcc, _, headers  = pcc_api.pccs_post_with_http_info({
          properties: {
            name: config[:name],
            description: config[:description],
          }.compact,
        })

        dot = ui.color('.', :magenta)
        api_client.wait_for { print dot; is_done? get_request_id headers }

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
