require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudContainerRegistryTokenCreate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud container registry token create (options)'

      option :registry_id,
              short: '-R REGISTRY_ID',
              long: '--registry-id REGISTRY_ID',
              description: 'The ID of the Container Registry.'

      option :name,
              short: '-n TOKEN_NAME',
              long: '--name TOKEN_NAME',
              description: 'The name of the Container Registry.'

      option :expiry_date,
              short: '-e EXPIRY_DATE',
              long: '--expiry-date EXPIRY_DATE',
              description: 'The expiry of the Container Registry Token.'

      option :status,
              short: '-s STATUS',
              long: '--status STATUS',
              description: 'The status of the Container Registry Token.'

      option :scopes,
              long: '--scopes [SCOPE]',
              description: 'The scopes of the Container Registry Token.'

      def initialize(args = [])
        super(args)
        @description =
        'Create a new Container Registry Token.'
        @directory = 'container-registry'
        @required_options = [:registry_id, :name]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        config[:scopes] = JSON[config[:scopes]] if config[:scopes] && config[:scopes].instance_of?(String)

        config[:scopes] = config[:scopes].map do |scope|
          IonoscloudContainerRegistry::Scope.new(
            actions: scope['actions'],
            name: String(scope['name']),
            type: String(scope['type']),
          )
        end if config[:scopes]

        print "#{ui.color('Creating Container Registry Token...', :magenta)}"

        registry_token = IonoscloudContainerRegistry::TokensApi.new(api_client_container_registry).registries_tokens_post(
          config[:registry_id],
          IonoscloudContainerRegistry::PostTokenInput.new(
            properties: IonoscloudContainerRegistry::PostTokenProperties.new(
              name: config[:name],
              expiry_date: config[:expiry_date],
              status: config[:status],
              scopes: config[:scopes],
            ),
          ),
        )

        print_registry_token(registry_token)
      end
    end
  end
end
