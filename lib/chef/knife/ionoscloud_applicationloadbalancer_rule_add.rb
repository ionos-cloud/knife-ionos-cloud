require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudApplicationloadbalancerRuleAdd < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud applicationloadbalancer rule add (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'Name of the data center'

      option :application_loadbalancer_id,
              short: '-L NETWORK_LOADBALANCER_ID',
              long: '--application-loadbalancer NETWORK_LOADBALANCER_ID',
              description: 'ID of the Application Loadbalancer'

      option :name,
              short: '-n NAME',
              long: '--name NAME',
              description: 'A name of that Application Load Balancer forwarding rule'

      option :protocol,
              long: '--protocol PROTOCOL',
              description: 'Protocol of the balancing',
              default: 'HTTP'

      option :listener_ip,
              short: '-i LISTENER_IP',
              long: '--ip LISTENER_IP',
              description: 'Listening IP. (inbound)'

      option :listener_port,
              short: '-p LISTENER_PORT',
              long: '--port LISTENER_PORT',
              description: 'Listening port number. (inbound) (range: 1 to 65535)'

      option :client_timeout,
              long: '--client-timeout CLIENT_TIMEOUT',
              description: 'ClientTimeout is expressed in milliseconds. This inactivity timeout applies when '\
              'the client is expected to acknowledge or send data. If unset the default of 50 seconds will be used.',
              default: 50

      option :server_certificates,
              long: '--certificates SERVER_CERTIFICATES',
              description: 'Array of server certificates'

      option :http_rules,
              long: '--http-rules HTTP_RULES',
              description: 'Array of HTTP Rules'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Adds a Forwarding Rule to a Application Load Balancer under a data center.'
        @required_options = [
          :datacenter_id, :application_loadbalancer_id, :name, :listener_ip, :listener_port, :ionoscloud_username, :ionoscloud_password,
        ]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        application_loadbalancers_api = Ionoscloud::ApplicationLoadBalancersApi.new(api_client)

        if config[:server_certificates] && config[:server_certificates].instance_of?(String)
          config[:server_certificates] = config[:server_certificates].split(',')
        end

        unless config[:http_rules].nil?
          config[:http_rules] = JSON[config[:http_rules]] if config[:http_rules].instance_of?(String)

          config[:http_rules].map! do |target|
            Ionoscloud::ApplicationLoadBalancerHttpRule.new(
              name: target['name'],
              type: target['type'],
              target_group: target['target_group'],
              drop_query: target['drop_query'],
              location: target['location'],
              status_code: target['status_code'],
              response_message: target['response_message'],
              content_type: target['content_type'],
              conditions: target['conditions'].nil? ? nil : target['conditions'].map do
                |condition|
                Ionoscloud::ApplicationLoadBalancerHttpRuleCondition.new(
                  type: condition['type'],
                  condition: condition['condition'],
                  negate: condition['negate'],
                  key: condition['key'],
                  value: condition['value'],
                )
              end,
            )
          end
        end

        application_loadbalancer_forwarding_rule = Ionoscloud::ApplicationLoadBalancerForwardingRule.new(
          properties: Ionoscloud::ApplicationLoadBalancerForwardingRuleProperties.new(
            name: config[:name],
            protocol: config[:protocol],
            listener_ip: config[:listener_ip],
            listener_port: config[:listener_port],
            health_check: Ionoscloud::ApplicationLoadBalancerForwardingRuleHealthCheck.new(
              client_timeout: config[:client_timeout],
            ),
            server_certificates: config[:server_certificates],
            http_rules: config[:http_rules],
          ),
        )

        _, _, headers = application_loadbalancers_api.datacenters_applicationloadbalancers_forwardingrules_post_with_http_info(
          config[:datacenter_id], config[:application_loadbalancer_id], application_loadbalancer_forwarding_rule,
        )

        print "#{ui.color('Adding the rule to the Application Loadbalancer...', :magenta)}"
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
