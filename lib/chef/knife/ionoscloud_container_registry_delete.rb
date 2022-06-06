require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudContainerRegistryDelete < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud container registry delete (options) REGISTRY_ID [REGISTRY_ID]'

      option :wait_name_available,
              long: '--wait',
              boolean: true,
              description: 'Boolean indicating if the command should wait for the name to become available. Defaults to false.'

      def initialize(args = [])
        super(args)
        @description ='Delete a Container Registry'
        @directory = 'container-registry'
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        registries_api = IonoscloudContainerRegistry::RegistriesApi.new(api_client_container_registry)

        @name_args.each do |registry_id|
          begin
            registry = registries_api.registries_find_by_id(registry_id)
          rescue Ionoscloud::ApiError => err
            raise err unless err.code == 404
            ui.error("Container Registry ID #{registry_id} not found. Skipping.")
            next
          end

          print_registry(registry)
          puts "\n"

          begin
            confirm('Do you really want to delete this Container Registry')
          rescue SystemExit
            next
          end

          registries_api.registries_delete(registry_id)

          unless config[:wait_name_available].nil?
            api_client_container_registry.wait_for do
              begin
                IonoscloudContainerRegistry::NamesApi.new(api_client_container_registry).names_find_by_name(registry.properties.name)
              rescue IonoscloudContainerRegistry::ApiError => e
                return true if e.code == 404
                raise e
              end
              false
            end
          end
          ui.warn("Deleted Container Registry #{registry.id}.")
        end
      end
    end
  end
end
