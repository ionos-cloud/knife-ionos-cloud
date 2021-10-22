require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudApplicationloadbalancerRuleHttpruleAdd < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud applicationloadbalancer rule httprule add (options)'

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

      option :type,
              short: '-t TYPE',
              long: '--type TYPE',
              description: 'Type of the Http Rule.'

      option :target_group,
              long: '--target-group TARGET_GROUP_ID',
              description: 'The UUID of the target group; mandatory and only valid for FORWARD action.'

      option :drop_query,
              short: '-q QUERY',
              long: '--query QUERY',
              description: 'Default is false; valid only for REDIRECT action.'

      option :location,
              short: '-l LOCATION',
              long: '--location LOCATION',
              description: 'The location for redirecting; mandatory and valid only for REDIRECT action.'

      option :status_code,
              long: '--code STATUS_CODE',
              description: 'Valid only for action REDIRECT and STATIC; on REDIRECT action default is 301 '\
              'and it can take the values 301, 302, 303, 307, 308; on STATIC action default is 503 and it can take a value between 200 and 599'

      option :response_message,
              short: '-m MESSAGE',
              long: '--message MESSAGE',
              description: 'The response message of the request; mandatory for STATIC action'

      option :content_type,
              long: '--content-type CONTENT_TYPE',
              description: 'Valid only for action STATIC'

      option :conditions,
              long: '--conditions CONDITIONS',
              description: 'Array of conditions for the HTTP Rule'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Adds a Http Rule to a Application Load Balancer Forwarding Rule under a data center or updates it if one already exists.'
        @required_options = [
          :datacenter_id, :application_loadbalancer_id, :forwarding_rule_id, :name, :type, :ionoscloud_username, :ionoscloud_password,
        ]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        application_loadbalancers_api = Ionoscloud::ApplicationLoadBalancersApi.new(api_client)

        application_load_balancer_rule = application_loadbalancers_api.datacenters_applicationloadbalancers_forwardingrules_find_by_forwarding_rule_id(
          config[:datacenter_id], config[:application_loadbalancer_id], config[:forwarding_rule_id],
        )

        existing_http_rule = application_load_balancer_rule.properties.http_rules.nil? ? nil : application_load_balancer_rule.properties.http_rules.find do
          |rule|
          rule.name == config[:name]
        end

        unless config[:conditions].nil?
          config[:conditions] = JSON[config[:conditions]] if config[:conditions].instance_of?(String)

          config[:conditions].map! do |condition|
            Ionoscloud::ApplicationLoadBalancerHttpRuleCondition.new(
              type: condition['type'],
              condition: condition['condition'],
              negate: condition['negate'],
              key: condition['key'],
              value: condition['value'],
            )
          end
        end

        if existing_http_rule
          existing_http_rule.type = config[:type] || existing_http_rule.type
          existing_http_rule.target_group = config[:target_group] || existing_http_rule.target_group
          existing_http_rule.drop_query = config[:drop_query] || existing_http_rule.drop_query
          existing_http_rule.location = config[:location] || existing_http_rule.location
          existing_http_rule.status_code = config[:status_code] || existing_http_rule.status_code
          existing_http_rule.response_message = config[:response_message] || existing_http_rule.response_message
          existing_http_rule.content_type = config[:content_type] || existing_http_rule.content_type
          existing_http_rule.conditions = config[:conditions] || existing_http_rule.conditions
        else
          application_loadbalancer_forwarding_rule_httprule = Ionoscloud::ApplicationLoadBalancerHttpRule.new(
            name: config[:name],
            type: config[:type],
            target_group: config[:target_group],
            drop_query: config[:drop_query],
            location: config[:location],
            status_code: config[:status_code],
            response_message: config[:response_message],
            content_type: config[:content_type],
            conditions: config[:conditions],
          )

          if application_load_balancer_rule.properties.http_rules.nil?
            application_load_balancer_rule.properties.http_rules = [application_loadbalancer_forwarding_rule_httprule]
          else
            application_load_balancer_rule.properties.http_rules << application_loadbalancer_forwarding_rule_httprule
          end
        end

        _, _, headers  = application_loadbalancers_api.datacenters_applicationloadbalancers_forwardingrules_patch_with_http_info(
          config[:datacenter_id],
          config[:application_loadbalancer_id],
          config[:forwarding_rule_id],
          Ionoscloud::ApplicationLoadBalancerForwardingRuleProperties.new({
            http_rules: application_load_balancer_rule.properties.http_rules,
          }),
        )

        print "#{ui.color('Adding the Http Rule to the Application Loadbalancer Forwarding Rule...', :magenta)}"
        dot = ui.color('.', :magenta)
        api_client.wait_for { print dot; is_done? get_request_id headers }

        print_application_loadbalancer(
          application_loadbalancers_api.datacenters_applicationloadbalancers_find_by_application_load_balancer_id(
            config[:datacenter_id], config[:application_loadbalancer_id], depth: 2,
          ),
        )
      end
    end
  end
end
