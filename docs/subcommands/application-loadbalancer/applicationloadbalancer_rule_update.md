# ApplicationloadbalancerRuleUpdate

Updates information about a Ionoscloud Application LoadBalancer Forwarding Rule.

```text
knife ionoscloud applicationloadbalancer rule update (options)
```

## Available options:

### Required options:

* datacenter\_id
* application\_loadbalancer\_id
* forwarding\_rule\_id
* ionoscloud\_username
* ionoscloud\_password

```text
    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        iD of the data center (required)

    application_loadbalancer_id: --application-loadbalancer APPLICATION_LOADBALANCER_ID, -L APPLICATION_LOADBALANCER_ID
        iD of the Application Loadbalancer (required)

    forwarding_rule_id: --forwarding-rule FORWARDING_RULE_ID, -R FORWARDING_RULE_ID
        iD of the Application Loadbalancer Forwarding Rule (required)

    name: --name NAME, -n NAME
        a name of that Application Load Balancer forwarding rule

    protocol: --protocol PROTOCOL
        protocol of the balancing

    listener_ip: --ip LISTENER_IP, -i LISTENER_IP
        listening IP. (inbound)

    listener_port: --port LISTENER_PORT, -p LISTENER_PORT
        listening port number. (inbound) (range: 1 to 65535)

    client_timeout: --client-timeout CLIENT_TIMEOUT
        clientTimeout is expressed in milliseconds. This inactivity timeout applies when the client is expected to acknowledge or send data. If unset the default of 50 seconds will be used.

    server_certificates: --certificates SERVER_CERTIFICATES
        array of server certificates

    http_rules: --http-rules HTTP_RULES
        array of HTTP Rules

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    ionoscloud_url: --url URL
        the Ionoscloud API URL

```
## Example

```text
knife ionoscloud applicationloadbalancer rule update --extra-config EXTRA_CONFIG_FILE_PATH --datacenter-id DATACENTER_ID --application-loadbalancer APPLICATION_LOADBALANCER_ID --forwarding-rule FORWARDING_RULE_ID --name NAME --protocol PROTOCOL --ip LISTENER_IP --port LISTENER_PORT --client-timeout CLIENT_TIMEOUT --certificates SERVER_CERTIFICATES --http-rules HTTP_RULES --username USERNAME --password PASSWORD --url URL
```
