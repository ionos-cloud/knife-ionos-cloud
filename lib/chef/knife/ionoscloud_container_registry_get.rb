require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudContainerRegistryGet < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud container registry get (options)'

      option :registry_id,
              short: '-R REGISTRY_ID',
              long: '--registry-id REGISTRY_ID',
              description: 'The ID of the Container Registry.'

      def initialize(args = [])
        super(args)
        @description =
        'Retrieves information about a Container Registry.'
        @directory = 'container-registry'
        @required_options = [:registry_id]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        print_registry(IonoscloudContainerRegistry::RegistriesApi.new(api_client_container_registry).registries_find_by_id(
          config[:registry_id],
        ))
      end
    end
  end
end
