require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudLabelList < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud label list (options)'

      option :type,
              short: '-T RESOURCE_TYPE',
              long: '--resource-type RESOURCE_TYPE',
              description: 'Type of the resource to be labeled.'

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
        'List all Labels available to the user. Specify the type and required resource ID '\
        'to list labels for a specific resource instead.'
        @directory = 'compute-engine'
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        label_api = Ionoscloud::LabelsApi.new(api_client)
        opts = { depth: 1 }

        case config[:type]
        when 'datacenter'
          validate_required_params([:resource_id], config)
          labels = label_api.datacenters_labels_get(config[:resource_id], opts)
        when 'server'
          validate_required_params([:datacenter_id, :resource_id], config)
          labels = label_api.datacenters_servers_labels_get(config[:datacenter_id], config[:resource_id], opts)
        when 'volume'
          validate_required_params([:datacenter_id, :resource_id], config)
          labels = label_api.datacenters_volumes_labels_get(config[:datacenter_id], config[:resource_id], opts)
        when 'ipblock'
          validate_required_params([:resource_id], config)
          labels = label_api.ipblocks_labels_get(config[:resource_id], opts)
        when 'snapshot'
          validate_required_params([:resource_id], config)
          labels = label_api.snapshots_labels_get(config[:resource_id], opts)
        else
          ui.warn("#{config[:type]} is not a valid Resource Type. Returning all available labels.") if !config[:type].nil?
          labels = label_api.labels_get(opts)
        end

        label_list = [
          ui.color('Resource ID', :bold),
          ui.color('Resource Type', :bold),
          ui.color('Label key', :bold),
          ui.color('Value', :bold),
        ]

        labels.items.each do |label|
          label_list << (label.properties.respond_to?(:resource_id) ? label.properties.resource_id : config[:resource_id])
          label_list << (label.properties.respond_to?(:resource_type) ? label.properties.resource_type : config[:type])
          label_list << label.properties.key
          label_list << label.properties.value
        end

        puts ui.list(label_list, :uneven_columns_across, 4)
      end
    end
  end
end
