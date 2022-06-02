require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudContainerRegistryCreate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud container registry create (options)'

      option :name,
              short: '-n REGISTRY_NAME',
              long: '--name REGISTRY_NAME',
              description: 'The name of the Container Registry.'

      option :location,
              short: '-l lOCATION',
              long: '--location lOCATION',
              description: 'The location of the Container Registry.'

      option :garbage_collection_time,
              long: '--garbage_collection-time GARBAGE_COLLECTION_TIME',
              description: 'Time of the day when to perform the garbage_collection.'

      option :garbage_collection_days,
              long: '--garbage_collection-days GARBAGE_COLLECTION_DAY [GARBAGE_COLLECTION_DAY]',
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
        'Create a new Container Registry.'
        @directory = 'container-registry'
        @required_options = [:name, :location]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        config[:garbage_collection_days] = config[:garbage_collection_days].split(',') if config[:garbage_collection_days] && config[:garbage_collection_days].instance_of?(String)
        config[:maintenance_days] = config[:maintenance_days].split(',') if config[:maintenance_days] && config[:maintenance_days].instance_of?(String)

        print "#{ui.color('Creating Container Registry...', :magenta)}"

        garbage_collection_schedule = maintenance_window = nil

        garbage_collection_schedule = IonoscloudContainerRegistry::WeeklySchedule.new(
          days: config[:garbage_collection_days],
          time: config[:garbage_collection_time],
        ) if config[:garbage_collection_days] || config[:garbage_collection_time]

        maintenance_window = IonoscloudContainerRegistry::WeeklySchedule.new(
          days: config[:maintenance_days],
          time: config[:maintenance_time],
        ) if config[:maintenance_days] || config[:maintenance_time]

        registry = IonoscloudContainerRegistry::RegistriesApi.new(api_client_container_registry).registries_post(
          IonoscloudContainerRegistry::PostRegistryInput.new(
            properties: IonoscloudContainerRegistry::PostRegistryProperties.new(
              garbage_collection_schedule: garbage_collection_schedule,
              location: config[:location],
              maintenance_window: maintenance_window,
              name: config[:name],
            )
          )
        )

        print_registry(registry)
      end
    end
  end
end
