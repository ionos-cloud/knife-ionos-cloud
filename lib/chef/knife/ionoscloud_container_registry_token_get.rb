require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudContainerRegistryTokenGet < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud container registry token get (options)'

      option :registry_id,
              short: '-R REGISTRY_ID',
              long: '--registry-id REGISTRY_ID',
              description: 'The ID of the Container Registry.'

      option :token_id,
              short: '-T TOKEN_ID',
              long: '--token-id TOKEN_ID',
              description: 'The ID of the Container Registry Token.'

      def initialize(args = [])
        super(args)
        @description =
        'Retrieves information about a Container RegistryToken.'
        @directory = 'container-registry'
        @required_options = [:registry_id, :token_id]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        print_registry_token(IonoscloudContainerRegistry::TokensApi.new(api_client_container_registry).registries_tokens_find_by_id(
          config[:registry_id], config[:token_id]
        ))
      end
    end
  end
end
