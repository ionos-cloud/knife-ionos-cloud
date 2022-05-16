require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudDatacenterList < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud datacenter list'

      def initialize(args = [])
        super(args)
        @description =
        'Ionoscloud introduces the concept of virtual data centers. '\
        'These are logically separated from one another and allow you '\
        'to have a self-contained environment for all servers, volumes, '\
        'networking, and other resources. The goal is to give you the same '\
        'experience as you would have if you were running your own physical '\
        'data center. A list of available data centers can be obtained with the following command.'
        @directory = 'compute-engine'
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        datacenter_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Description', :bold),
          ui.color('Location', :bold),
          ui.color('CPU Architectures', :bold),
          ui.color('Version', :bold),
        ]

        datacenter_api = Ionoscloud::DataCentersApi.new(api_client)

        datacenter_api.datacenters_get({ depth: 1 }).items.each do |datacenter|
          datacenter_list << datacenter.id
          datacenter_list << datacenter.properties.name
          datacenter_list << datacenter.properties.description || ''
          datacenter_list << datacenter.properties.location
          datacenter_list << datacenter.properties.cpu_architecture.map { |arch| arch.cpu_family }
          datacenter_list << datacenter.properties.version.to_s
        end

        puts ui.list(datacenter_list, :uneven_columns_across, 6)
      end
    end
  end
end
