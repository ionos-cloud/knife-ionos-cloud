require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudAutoscailingGroupList < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud vm Autoscailing Group list'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'retrieves a list of all vm Autoscailing Groups.'
        @required_options = [:ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        autoscailing_group_list = [
          ui.color('ID', :bold),
          ui.color('Type', :bold),
          ui.color('Max Replica Count', :bold),
          ui.color('Min Replica Count', :bold),
          ui.color('Target Replica Count', :bold),
          ui.color('Name', :bold),
          ui.color('Policy', :bold),
          ui.color('Replica Configuration', :bold),
          ui.color('Datacenter', :bold),
          ui.color('Location', :bold),
        ]

        groups_api = IonoscloudAutoscaling::GroupsApi.new(api_client)

        groups_api.autoscaling_groups_get({ depth: 1 }).items.each do |group|
          autoscailing_group_list << group.id
          autoscailing_group_list << group.type
          autoscailing_group_list << group.properties.max_replica_count
          autoscailing_group_list << group.properties.min_replica_count
          autoscailing_group_list << group.properties.target_replica_count
          autoscailing_group_list << group.properties.name
          autoscailing_group_list << group.properties.policy # todo vezi daca afiseaza ca json sau trebuie pus camp cu camp
          autoscailing_group_list << group.properties.replica_configuration # todo vezi daca afiseaza ca json sau trebuie pus camp cu camp
          autoscailing_group_list << group.properties.datacenter # todo vezi daca afiseaza ca json sau trebuie pus camp cu camp
          autoscailing_group_list << group.properties.location
        end

        puts ui.list(autoscailing_group_list, :uneven_columns_across, 10)
      end
    end
  end
end