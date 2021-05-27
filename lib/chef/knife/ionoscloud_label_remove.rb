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

      option :resource_id,
              short: '-R RESOURCE_ID',
              long: '--resource-id RESOURCE_ID',
              description: 'ID of the resource.'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Remove a Label from a Resource.'
        @required_options = [:type, :resource_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        validate_required_params(@required_options, config)

        label_api = Ionoscloud::LabelsApi.new(api_client)

        args = [config[:resource_id]]

        case config[:type]
        when 'datacenter'
          method = label_api.method(:datacenters_labels_delete)
        when 'server'
          validate_required_params([:datacenter_id], config)

          method = label_api.method(:datacenters_servers_labels_delete)
          args = [config[:datacenter_id], config[:resource_id]]
        when 'volume'
          validate_required_params([:datacenter_id], config)

          method = label_api.method(:datacenters_volumes_labels_delete)
          args = [config[:datacenter_id], config[:resource_id]]
        when 'ipblock'
          method = label_api.method(:ipblocks_labels_delete)
        when 'snapshot'
          method = label_api.method(:snapshots_labels_delete)
        else
          ui.error("#{config[:type]} is not a valid Resource Type.")
          exit(1)
        end

        @name_args.each do |label_key|
          begin
            method.call(*args, label_key)
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("Label #{label_key} not found. Skipping.")
            next
          end
          ui.warn("Removed Label #{label_key} from #{config[:type]} #{config[:resource_id]}.")
        end
      end
    end
  end
end
