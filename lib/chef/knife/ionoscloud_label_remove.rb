require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudLabelRemove < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud label remove LABEL_KEY [LABEL_KEY] (options)'

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
        'Remove a Label from a Resource.'
        @required_options = [:type, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        validate_required_params(@required_options, config)
        
        label_api = Ionoscloud::LabelApi.new(api_client)

        case config[:type]
        when 'datacenter'
          validate_required_params([:datacenter_id], config)

          method = label_api.method(:datacenters_labels_delete)
          args = [config[:datacenter_id]]
        when 'server'
          validate_required_params([:datacenter_id, :server_id], config)

          method = label_api.method(:datacenters_servers_labels_delete)
          args = [config[:datacenter_id, :server_id]]
        when 'volume'
          validate_required_params([:datacenter_id, :volume_id], config)

          method = label_api.method(:datacenters_volumes_labels_delete)
          args = [config[:datacenter_id], config[:volume_id]]
        when 'ipblock'
          validate_required_params([:ipblock_id], config)

          method = label_api.method(:ipblocks_labels_delete)
          args = [config[:ipblock_id]]
        when 'snapshot'
          validate_required_params([:snapshot_id], config)

          method = label_api.method(:snapshots_labels_delete)
          args = [config[:snapshot_id]]
        else
          ui.error("#{config[:type]} is not a valid Resource Type.")
        end

        @name_args.each do |label_key|
          begin
            method.call(config[:datacenter_id], label_key)
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("Label #{label_key} not found. Skipping.")
            next
          end
          ui.warn("Removed Label #{config[:key]} from #{config[:type]} #{config[:"#{config[:type]}_id"]}.")
        end
      end
    end
  end
end
