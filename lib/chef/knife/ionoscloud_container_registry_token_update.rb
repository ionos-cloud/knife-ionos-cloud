require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudContainerRegistryTokenUpdate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud container registry token update (options)'

      option :registry_id,
              short: '-R REGISTRY_ID',
              long: '--registry-id REGISTRY_ID',
              description: 'ID of the registry.'

      option :token_id,
              short: '-T TOKEN_ID',
              long: '--token-id TOKEN_ID',
              description: 'ID of the registry token.'

      option :status,
              short: '-s STATUS',
              long: '--status STATUS',
              description: 'The status of the Container Registry Token.'

      def initialize(args = [])
        super(args)
        @description =
        'Updates information about a Container Registry Token'
        @directory = 'container-registry'
        @required_options = [:registry_id, :token_id]
        @updatable_fields = [:status]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        tokens_api = IonoscloudContainerRegistry::TokensApi.new(api_client_container_registry)

        if @updatable_fields.map { |el| config[el] }.any?
          print "#{ui.color('Updating Container Registry Token...', :magenta)}"
          
          tokens_api.registries_tokens_patch(
            config[:registry_id],
            config[:token_id],
            IonoscloudContainerRegistry::PatchTokenInput.new(
              status: config[:status],
            ),
          )
        else
          ui.warn("Nothing to update, please set one of the attributes #{@updatable_fields}.")
        end

        print_registry_token(tokens_api.registries_tokens_find_by_id(config[:registry_id], config[:token_id]))
      end
    end
  end
end
