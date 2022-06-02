require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudContainerRegistryUpdate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud container registry update (options)'

      option :registry_id,
              short: '-R REGISTRY_ID',
              long: '--registry-id REGISTRY_ID',
              description: 'ID of the registry.'

      option :garbage_collection_time,
              long: '--garbage-collection-time GARBAGE_COLLECTION_TIME',
              description: 'Time of the day when to perform the garbage_collection.'

      option :garbage_collection_days,
              long: '--garbage-collection-days GARBAGE_COLLECTION_DAY [GARBAGE_COLLECTION_DAY]',
              description: 'Days for the garbage_collection windows.'

      option :maintenance_time,
              long: '--maintenance-time MAINTENANCE_TIME',
              description: 'Time of the day when to perform the maintenance.'

      option :maintenance_days,
              long: '--maintenance-days MAINTENANCE_DAY [MAINTENANCE_DAY]',
              description: 'Days for the maintenance windows.'

      def initialize(args = [])
        super(args)
        @description =
        'Updates information about a Container Registry'
        @directory = 'container-registry'
        @required_options = [:registry_id]
        @updatable_fields = [:garbage_collection_time, :garbage_collection_days, :maintenance_time, :maintenance_days]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        config[:garbage_collection_days] = config[:garbage_collection_days].split(',') if config[:garbage_collection_days] && config[:garbage_collection_days].instance_of?(String)
        config[:maintenance_days] = config[:maintenance_days].split(',') if config[:maintenance_days] && config[:maintenance_days].instance_of?(String)

        registries_api = IonoscloudContainerRegistry::RegistriesApi.new(api_client_container_registry)

        if @updatable_fields.map { |el| config[el] }.any?
          print "#{ui.color('Updating Container Registry...', :magenta)}"

          garbage_collection_schedule = maintenance_window = nil

          garbage_collection_schedule = IonoscloudContainerRegistry::WeeklySchedule.new(
            days: config[:garbage_collection_days],
            time: config[:garbage_collection_time],
          ) if config[:garbage_collection_days] || config[:garbage_collection_time]

          maintenance_window = IonoscloudContainerRegistry::WeeklySchedule.new(
            days: config[:maintenance_days],
            time: config[:maintenance_time],
          ) if config[:maintenance_days] || config[:maintenance_time]
          
          registries_api.registries_patch(
            config[:registry_id],
            IonoscloudContainerRegistry::PatchRegistryInput.new(
              garbage_collection_schedule: garbage_collection_schedule,
              maintenance_window: maintenance_window,
            ),
          )
        else
          ui.warn("Nothing to update, please set one of the attributes #{@updatable_fields}.")
        end

        print_registry(registries_api.registries_find_by_id(config[:registry_id]))
      end
    end
  end
end
