require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudApplicationloadbalancerRuleHttpruleConditionRemove < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud applicationloadbalancer rule httprule condition remove (options)'

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

      option :http_rule_name,
              short: '-n HTTP_RULE_NAME',
              long: '--name HTTP_RULE_NAME',
              description: 'The name of a Application Load Balancer http rule; unique per forwarding rule'

      option :type,
              short: '-t TYPE',
              long: '--type TYPE',
              description: 'Type of the Http Rule condition.'

      option :condition,
              long: '--condition CONDITION',
              description: 'Matching rule for the Http Rule condition attribute; mandatory for HEADER, PATH, '\
              'QUERY, METHOD, HOST and COOKIE types; must be null when type is SOURCE_IP.'

      option :key,
              short: '-k KEY',
              long: '--key KEY',
              description: 'Must be null when type is SOURCE_IP.'

      option :value,
              short: '-v VALUE',
              long: '--value STATUS_CODE',
              description: 'Mandatory for conditions CONTAINS, EQUALS, MATCHES, STARTS_WITH, ENDS_WITH; '\
              'must be null when condition is EXISTS; should be a valid CIDR if provided and if type is SOURCE_IP.'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Adds a condition to a Application Load Balancer Http Rule.'
        @required_options = [
          :datacenter_id, :application_loadbalancer_id, :forwarding_rule_id,
          :http_rule_name, :type, :condition, :ionoscloud_username, :ionoscloud_password,
        ]
      end

      def run
        $stdout.sync = true
        validate_required_params(@required_options, config)

        application_loadbalancers_api = Ionoscloud::ApplicationLoadBalancersApi.new(api_client)


        application_load_balancer_rule = application_loadbalancers_api.datacenters_applicationloadbalancers_forwardingrules_find_by_forwarding_rule_id(
          config[:datacenter_id], config[:application_loadbalancer_id], config[:forwarding_rule_id],
        )

        http_rule = application_load_balancer_rule.properties.http_rules.nil? ? nil : application_load_balancer_rule.properties.http_rules.find do
          |rule|
          rule.name == config[:http_rule_name]
        end

        if http_rule
          new_condition = Ionoscloud::ApplicationLoadBalancerHttpRuleCondition.new(
            type: config[:type],
            condition: config[:condition],
            negate: config[:negate],
            key: config[:key],
            value: config[:value],
          )

          if http_rule.conditions.nil?
            http_rule.conditions = [new_condition]
          else
            http_rule.conditions << new_condition
          end

          _, _, headers  = application_loadbalancers_api.datacenters_applicationloadbalancers_forwardingrules_patch_with_http_info(
            config[:datacenter_id],
            config[:application_loadbalancer_id],
            config[:forwarding_rule_id],
            Ionoscloud::ApplicationLoadBalancerForwardingRuleProperties.new(
              http_rules: application_load_balancer_rule.properties.http_rules,
            ),
          )

          print "#{ui.color('Adding the Condition to the Application Loadbalancer Http Rule...', :magenta)}"
          dot = ui.color('.', :magenta)
          api_client.wait_for { print dot; is_done? get_request_id headers }
        else
          ui.warn("Http Rule #{config[:http_rule_name]} not found.")
        end

        print_application_loadbalancer(application_loadbalancers_api.datacenters_applicationloadbalancers_find_by_application_load_balancer_id(
          config[:datacenter_id], config[:application_loadbalancer_id], depth: 2,
        ))
      end
    end
  end
end
