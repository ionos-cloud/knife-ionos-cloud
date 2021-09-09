require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudApplicationloadbalancerRuleRemove < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud applicationloadbalancer rule remove RULE_ID [RULE_ID] (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'The ID of the data center'

      option :application_loadbalancer_id,
              short: '-L NETWORK_LOADBALANCER_ID',
              long: '--application-loadbalancer NETWORK_LOADBALANCER_ID',
              description: 'ID of the Application Loadbalancer'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Removes the specified rules from a Application Loadbalancer under a data center.'
        @required_options = [:datacenter_id, :application_loadbalancer_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        return unless @name_args.length > 0

        application_loadbalancers_api = Ionoscloud::ApplicationLoadBalancersApi.new(api_client)

        headers_to_wait = []
        removed_rules = []
        @name_args.each do |rule_id|
          begin
            _, _, headers = application_loadbalancers_api.datacenters_applicationloadbalancers_forwardingrules_delete_with_http_info(
              config[:datacenter_id], config[:application_loadbalancer_id], rule_id,
            )
            headers_to_wait << headers
            removed_rules << rule_id
          rescue
            ui.warn("Error removing Forwarding Rule #{rule_id}. Skipping.")
          end
        end

        if removed_rules.empty?
          ui.warn("No valid rules to remove.")
        else
          print "#{ui.color("Removing rules #{removed_rules} from the Application Loadbalancer...", :magenta)}"
          dot = ui.color('.', :magenta)

          headers_to_wait.each { |headers| api_client.wait_for { print dot; is_done? get_request_id headers } }
        end

        print_application_loadbalancer(application_loadbalancers_api.datacenters_applicationloadbalancers_find_by_application_load_balancer_id(
          config[:datacenter_id], config[:application_loadbalancer_id], depth: 2,
        ))
      end
    end
  end
end
