require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudApplicationloadbalancerRuleHttpruleRemove < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud applicationloadbalancer rule httprule remove (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'Name of the data center'

      option :application_loadbalancer_id,
              short: '-L NETWORK_LOADBALANCER_ID',
              long: '--application-loadbalancer NETWORK_LOADBALANCER_ID',
              description: 'ID of the Application Loadbalancer'

      option :forwarding_rule_id,
              short: '-R FORWARDING_RULE_ID',
              long: '--forwarding-rule FORWARDING_RULE_ID',
              description: 'ID of the Application Loadbalancer Forwarding Rule'

      option :name,
              short: '-n NAME',
              long: '--name NAME',
              description: 'The name of a Application Load Balancer http rule; unique per forwarding rule'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Removes a Http Rule from a Application Load Balancer Forwarding Rule under a data center.'
        @required_options = [
          :datacenter_id, :application_loadbalancer_id, :forwarding_rule_id, :name, :ionoscloud_username, :ionoscloud_password,
        ]
      end

      def run
        $stdout.sync = true
        validate_required_params(@required_options, config)

        application_loadbalancers_api = Ionoscloud::ApplicationLoadBalancersApi.new(api_client)


        application_load_balancer_rule = application_loadbalancers_api.datacenters_applicationloadbalancers_forwardingrules_find_by_forwarding_rule_id(
          config[:datacenter_id], config[:application_loadbalancer_id], config[:forwarding_rule_id],
        )

        existing_http_rule = application_load_balancer_rule.properties.http_rules.nil? ? nil : application_load_balancer_rule.properties.http_rules.find do
          |rule|
          rule.name == config[:name]
        end

        if existing_http_rule
          application_load_balancer_rule.properties.http_rules = application_load_balancer_rule.properties.http_rules.reject do
            |rule|
            rule.name == config[:name]
          end

          _, _, headers  = application_loadbalancers_api.datacenters_applicationloadbalancers_forwardingrules_patch_with_http_info(
            config[:datacenter_id],
            config[:application_loadbalancer_id],
            config[:forwarding_rule_id],
            Ionoscloud::ApplicationLoadBalancerForwardingRuleProperties.new({
              http_rules: application_load_balancer_rule.properties.http_rules,
            }),
          )

          print "#{ui.color('Removing the Http Rule to the Application Loadbalancer Forwarding Rule...', :magenta)}"
          dot = ui.color('.', :magenta)
          api_client.wait_for { print dot; is_done? get_request_id headers }
        else
          ui.warn("Http Rule #{config[:name]} not found.")
        end

        print_application_loadbalancer(application_loadbalancers_api.datacenters_applicationloadbalancers_find_by_application_load_balancer_id(
          config[:datacenter_id], config[:application_loadbalancer_id], depth: 2,
        ))
      end
    end
  end
end
