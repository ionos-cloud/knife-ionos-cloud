require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudApplicationloadbalancerRuleUpdate < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud applicationloadbalancer rule update (options)'

      option :datacenter_id,
              short: '-D DATACENTER_ID',
              long: '--datacenter-id DATACENTER_ID',
              description: 'ID of the data center'

      option :application_loadbalancer_id,
              short: '-L APPLICATION_LOADBALANCER_ID',
              long: '--application-loadbalancer APPLICATION_LOADBALANCER_ID',
              description: 'ID of the Application Loadbalancer'

      option :forwarding_rule_id,
              short: '-R FORWARDING_RULE_ID',
              long: '--forwarding-rule FORWARDING_RULE_ID',
              description: 'ID of the Application Loadbalancer Forwarding Rule'

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
        'Updates information about a Ionoscloud Application LoadBalancer Forwarding Rule.'
        @directory = 'application-loadbalancer'
        @required_options = [:datacenter_id, :application_loadbalancer_id, :forwarding_rule_id]
        @updatable_fields = [:name, :protocol, :listener_ip, :listener_port, :client_timeout, :server_certificates, :http_rules]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        application_load_balancers_api = Ionoscloud::ApplicationLoadBalancersApi.new(api_client)

        if @updatable_fields.map { |el| config[el] }.any?
          print "#{ui.color('Updating Application LoadBalancer Forwarding Rule...', :magenta)}"

          config[:server_certificates] = config[:server_certificates].split(',') if config[:server_certificates] && config[:server_certificates].instance_of?(String)

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
                conditions: target['conditions'].nil? ? nil : target['conditions'].map do |condition|
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

          _, _, headers  = application_load_balancers_api.datacenters_applicationloadbalancers_forwardingrules_patch_with_http_info(
            config[:datacenter_id],
            config[:application_loadbalancer_id],
            config[:forwarding_rule_id],
            Ionoscloud::ApplicationLoadBalancerForwardingRuleProperties.new(
              name: config[:name],
              protocol: config[:protocol],
              listener_ip: config[:listener_ip],
              listener_port: config[:listener_port],
              client_timeout: config[:client_timeout],
              server_certificates: config[:server_certificates],
              http_rules: config[:http_rules],
            ),
          )

          dot = ui.color('.', :magenta)
          api_client.wait_for { print dot; is_done? get_request_id headers }
        else
          ui.warn("Nothing to update, please set one of the attributes #{@updatable_fields}.")
        end

        print_application_loadbalancer(
          application_load_balancers_api.datacenters_applicationloadbalancers_find_by_application_load_balancer_id(
            config[:datacenter_id], config[:application_loadbalancer_id], depth: 2,
          ),
        )
      end
    end
  end
end
