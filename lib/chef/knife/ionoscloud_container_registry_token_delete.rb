require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudContainerRegistryTokenDelete < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud container registry delete (options) REGISTRY_ID [REGISTRY_ID]'

      option :registry_id,
              short: '-R REGISTRY_ID',
              long: '--registry-id REGISTRY_ID',
              description: 'The ID of the Container Registry.'

      def initialize(args = [])
        super(args)
        @description ='Delete a Container Registry Token'
        @directory = 'container-registry'
        @required_options = [:registry_id]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        tokens_api = IonoscloudContainerRegistry::TokensApi.new(api_client_container_registry)

        @name_args.each do |token_id|
          begin
            token = tokens_api.registries_tokens_find_by_id(config[:registry_id], token_id)
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("Container Registry Token ID #{registry_id} not found. Skipping.")
            next
          end

          print_registry_token(token)
          puts "\n"

          begin
            confirm('Do you really want to delete this Container Registry Token')
          rescue SystemExit
            next
          end

          tokens_api.registries_tokens_delete(config[:registry_id], token_id)
          ui.warn("Deleted Container Registry Token #{token.id}.")
        end
      end
    end
  end
end
