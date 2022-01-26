require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudLabelAdd < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud label add (options)'

      option :type,
              short: '-T RESOURCE_TYPE',
              long: '--resource-type RESOURCE_TYPE',
              description: 'Type of the resource to be labeled. Must be one of [datacenter, server, volume, ipblock, snapshot]'

      option :key,
              short: '-K KEY',
              long: '--key KEY',
              description: 'Key of the label.'

      option :value,
              long: '--value VALUE',
              description: 'Value of the label.'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'ID of the data center.'

      option :resource_id,
              short: '-R RESOURCE_ID',
              long: '--resource-id RESOURCE_ID',
              description: 'ID of the resource.'

      def initialize(args = [])
        super(args)
        @description =
        'Add a Label to a Resource.'
        @directory = 'compute-engine'
        @required_options = [:type, :resource_id, :key, :value, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        label_api = Ionoscloud::LabelsApi.new(api_client)

        label_properties = {
          properties: {
            key: config[:key],
            value: config[:value],
          },
        }

        case config[:type]
        when 'datacenter'
          label = label_api.datacenters_labels_post(config[:resource_id], label_properties)
        when 'server'
          validate_required_params([:datacenter_id], config)
          label = label_api.datacenters_servers_labels_post(config[:datacenter_id], config[:resource_id], label_properties)
        when 'volume'
          validate_required_params([:datacenter_id], config)
          label = label_api.datacenters_volumes_labels_post(config[:datacenter_id], config[:resource_id], label_properties)
        when 'ipblock'
          label = label_api.ipblocks_labels_post(config[:resource_id], label_properties)
        when 'snapshot'
          label = label_api.snapshots_labels_post(config[:resource_id], label_properties)
        else
          ui.error("#{config[:type]} is not a valid Resource Type.")
          exit(1)
        end

        print "#{ui.color('Adding label...', :magenta)}"
        puts "\n"
        puts "#{ui.color('Resource ID', :cyan)}: #{config[:resource_id]}"
        puts "#{ui.color('Resource Type', :cyan)}: #{config[:type]}"
        puts "#{ui.color('Label Key', :cyan)}: #{label.properties.key}"
        puts "#{ui.color('Value', :cyan)}: #{label.properties.value}"
        puts 'done'
      end
    end
  end
end
