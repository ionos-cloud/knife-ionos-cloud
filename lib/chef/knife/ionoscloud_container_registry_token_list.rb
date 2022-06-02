require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudContainerRegistryTokenList < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud container registry token list'

      option :registry_id,
              short: '-R REGISTRY_ID',
              long: '--registry-id REGISTRY_ID',
              description: 'The ID of the Container Registry.'

      def initialize(args = [])
        super(args)
        @description =
        'Retrieve a list of all the Container Registry Tokens the supplied credentials have access to.'
        @directory = 'container-registry'
        @required_options = [:registry_id]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        registry_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Expiry Date', :bold),
          ui.color('Status', :bold),
        ]

        tokens_api = IonoscloudContainerRegistry::TokensApi.new(api_client_container_registry)

        tokens_api.registries_tokens_get(config[:registry_id]).items.each do |registry|
          registry_list << registry.id
          registry_list << registry.properties.name
          registry_list << registry.properties.expiry_date
          registry_list << registry.properties.status
        end

        puts ui.list(registry_list, :uneven_columns_across, 4)
      end
    end
  end
end
