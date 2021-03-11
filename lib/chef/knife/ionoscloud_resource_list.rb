require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudResourceList < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud resource list (options)'

      option :resource_type,
              short: '-t RESOURCE_TYPE',
              long: '--resource-type RESOURCE_TYPE',
              description: 'The specific type of resources to retrieve information about.'

      option :resource_id,
              short: '-R RESOURCE_ID',
              long: '--resource-id RESOURCE_ID',
              description: 'The ID of the specific resource to retrieve information about.'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        "No option: Retrieves a list of all resources and optionally their group associations. "\
        "Please Note: This API call can take a significant amount of time to return when there "\
        "are a large number of provisioned resources. You may wish to consult the next section "\
        "on how to list resources of a particular type.\n\n"
        "resource_type specified: Lists all shareable resources of a specific type. Optionally include their "\
        "association with groups, permissions that a group has for the resource, and "\
        "users that are members of the group. Because you are scoping your request to "\
        "a specific resource type, this API will likely return faster than querying */um/resources*.\n\n"\
        "The values available for resourceType are listed in this table:\n\n"\
        "| ResourceType | Description |\n"\
        "| datacenter | A virtual data center. |\n"\
        "| image | A private image that has been uploaded. |\n"\
        "| snapshot | A snapshot of a storage volume. |\n"\
        "| ipblock | An IP block that has been reserved. |\n"\
        "| k8s | A Kubernetes cluster. |\n\n"\
        "resource_type and resource_id specified: Retrieves a specific resource."\
        "**NOTE:** if you pass the *resource_id* option it is necessary to also pass the "\
        "*resource_type* option or a list of all resources will be returned."
        @required_options = [:ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        validate_required_params(@required_options, config)

        user_management_api = Ionoscloud::UserManagementApi.new(api_client)

        resource_list = [
          ui.color('ID', :bold),
          ui.color('Type', :bold),
          ui.color('Name', :bold),
        ]

        if config[:resource_id] && !config[:resource_type]
          ui.warn('Ignoring resource_id because no resource_type was specified.')
        end

        opts = { depth: 1 }

        if config[:resource_type] && config[:resource_id]
          resources = user_management_api.um_resources_find_by_type_and_id(config[:resource_type], config[:resource_id], opts)
        elsif config[:resource_type]
          resources = user_management_api.um_resources_find_by_type(config[:resource_type], opts)
        else
          resources = user_management_api.um_resources_get(opts)
        end

        resources.items.each do |resource|
          resource_list << resource.id
          resource_list << resource.type
          resource_list << (resource.properties.respond_to?(:name) ? resource.properties.name : '')
        end
        puts ui.list(resource_list, :uneven_columns_across, 3)
      end
    end
  end
end
