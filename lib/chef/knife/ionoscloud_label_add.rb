require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudLabelAdd < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud label add (options)'

      option :type,
              short: '-T RESOURCE_TYPE',
              long: '--resource-type RESOURCE_TYPE',
              description: 'Type of the resource to be labeled.'

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
        'Add a Label to a Resource.'
        @required_options = [:type, :key, :value, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        validate_required_params(@required_options, config)
        
        label_api = Ionoscloud::LabelApi.new(api_client)

        label_properties = {
          properties: {
            key: config[:key],
            value: config[:value],
          },
        }

        case config[:type]
        when 'datacenter'
          validate_required_params([:datacenter_id], config)
          label = label_api.datacenters_labels_post(config[:datacenter_id], label_properties)
        when 'server'
          validate_required_params([:datacenter_id, :server_id], config)
          label = label_api.datacenters_servers_labels_post(config[:datacenter_id], config[:server_id], label_properties)
        when 'volume'
          validate_required_params([:datacenter_id, :volume_id], config)
          label = label_api.datacenters_volumes_labels_post(config[:datacenter_id], config[:volume_id], label_properties)
        when 'ipblock'
          validate_required_params([:ipblock_id], config)
          label = label_api.ipblocks_labels_post(config[:ipblock_id], label_properties)
        when 'snapshot'
          validate_required_params([:snapshot_id], config)
          label = label_api.snapshots_labels_post(config[:snapshot_id], label_properties)
        else
          ui.error("#{config[:type]} is not a valid Resource Type.")
        end

        print "#{ui.color('Adding label...', :magenta)}"
        puts "\n"
        puts "#{ui.color('Resource ID', :cyan)}: #{config[:"#{config[:type]}_id"]}"
        puts "#{ui.color('Resource Type', :cyan)}: #{config[:type]}"
        puts "#{ui.color('Label Key', :cyan)}: #{label.properties.key}"
        puts "#{ui.color('Value', :cyan)}: #{label.properties.value}"
        puts 'done'
      end
    end
  end
end
