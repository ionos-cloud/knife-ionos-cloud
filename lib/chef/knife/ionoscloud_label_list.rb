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

      option :server_id,
              short: '-S SERVER_ID',
              long: '--server-id SERVER_ID',
              description: 'ID of the server.'

      option :volume_id,
              short: '-V VOLUME_ID',
              long: '--volume-id VOLUME_ID',
              description: 'ID of the volume.'

      option :ipblock_id,
              short: '-I IPBLOCK_ID',
              long: '--ipblock-id IPBLOCK_ID',
              description: 'ID of the ipblock.'

      option :snapshot_id,
              short: '-s SNAPSHOT_ID',
              long: '--snapshot-id SNAPSHOT_ID',
              description: 'ID of the snapshot.'
      
      attr_reader :description, :required_options
      
      def initialize(args = [])
        super(args)
        @description =
        'List all Labels available to the user. Specify the type and required resource ID '\
        'to list labels for a specific resource instead.'
        @required_options = [:ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        validate_required_params(@required_options, config)
        
        label_api = Ionoscloud::LabelApi.new(api_client)
        opts = { depth: 1 }

        case config[:type]
        when 'datacenter'
          validate_required_params([:datacenter_id], config)
          labels = label_api.datacenters_labels_get(config[:datacenter_id], opts)
        when 'server'
          validate_required_params([:datacenter_id, :server_id], config)
          labels = label_api.datacenters_servers_labels_get(config[:datacenter_id], config[:server_id], opts)
        when 'volume'
          validate_required_params([:datacenter_id, :volume_id], config)
          labels = label_api.datacenters_volumes_labels_get(config[:datacenter_id], config[:volume_id], opts)
        when 'ipblock'
          validate_required_params([:ipblock_id], config)
          labels = label_api.ipblocks_labels_get(config[:ipblock_id], opts)
        when 'snapshot'
          validate_required_params([:snapshot_id], config)
          labels = label_api.snapshots_labels_get(config[:datacenter_id], opts)
        else
          if !config[:type].nil?
            ui.warn("#{config[:type]} is not a valid Resource Type. Returning all available labels.")
          end
          labels = label_api.labels_get(opts)
        end

        label_list = [
          ui.color('Resource ID', :bold),
          ui.color('Resource Type', :bold),
          ui.color('Label key', :bold),
          ui.color('Value', :bold),
        ]

        labels.items.each do |label|
          label_list << (label.properties.respond_to?(:resource_id) ? label.properties.resource_id : config[:"#{config[:type]}_id"])
          label_list << (label.properties.respond_to?(:resource_type) ? label.properties.resource_type : config[:type])
          label_list << label.properties.key
          label_list << label.properties.value
        end

        puts ui.list(label_list, :uneven_columns_across, 4)
      end
    end
  end
end
