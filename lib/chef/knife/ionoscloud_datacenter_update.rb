require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudDatacenterUpdate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud datacenter update (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'ID of the data center'

      option :name,
              short: '-n NAME',
              long: '--name NAME',
              description: 'Name of the data center'

      option :description,
              long: '--description DESCRIPTION',
              description: 'Description of the data center'

      option :sec_auth_protection,
              long: '--sec-auth-protection SEC_AUTH_PROTECTION',
              description: 'Boolean value representing if the data center requires extra protection e.g. two factor protection'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Updates information about a Ionoscloud Datacenter.'
        @required_options = [:datacenter_id, :ionoscloud_username, :ionoscloud_password]
        @updatable_fields = [:name, :description, :sec_auth_protection]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        datacenter_api = Ionoscloud::DataCentersApi.new(api_client)

        if @updatable_fields.map { |el| config[el] }.any?
          print "#{ui.color('Updating data center...', :magenta)}"

          datacenter, _, headers  = datacenter_api.datacenters_patch_with_http_info(
            config[:datacenter_id],
            Ionoscloud::DatacenterProperties.new(
              name: config[:name],
              description: config[:description],
              sec_auth_protection: (config.key?(:sec_auth_protection) ? config[:sec_auth_protection].to_s.downcase == 'true' : nil),
            )
          )

          dot = ui.color('.', :magenta)
          api_client.wait_for { print dot; is_done? get_request_id headers }
        else
          ui.warn("Nothing to update, please set one of the attributes #{@updatable_fields}.")
        end

        print_datacenter(datacenter_api.datacenters_find_by_id(config[:datacenter_id]))
      end
    end
  end
end
