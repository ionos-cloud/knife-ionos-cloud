require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudContainerRegistryList < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud container registry list'

      def initialize(args = [])
        super(args)
        @description =
        'Retrieve a list of all the Container Registries the supplied credentials have access to.'
        @directory = 'container-registry'
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        registry_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Hostname', :bold),
          ui.color('Location', :bold),
          ui.color('Storage Used', :bold),
        ]

        registries_api = IonoscloudContainerRegistry::RegistriesApi.new(api_client_container_registry)

        registries_api.registries_get().items.each do |registry|
          registry_list << registry.id
          registry_list << registry.properties.name
          registry_list << registry.properties.hostname
          registry_list << registry.properties.location
          registry_list << "#{registry.properties.storage_usage.bytes} bytes"
        end

        puts ui.list(registry_list, :uneven_columns_across, 5)
      end
    end
  end
end
