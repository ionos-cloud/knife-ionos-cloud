# NetworkloadbalancerRuleTargetRemove

Adds a target to a Network Load Balancer Forwarding Rule under a data center.

```text
knife ionoscloud networkloadbalancer rule target remove (options)
```

## Available options:

### Required options:

* datacenter\_id
* network\_loadbalancer\_id
* forwarding\_rule\_id
* ip
* port
* ionoscloud\_username
* ionoscloud\_password

```text
    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        name of the data center (required)

    network_loadbalancer_id: --network-loadbalancer NETWORK_LOADBALANCER_ID, -L NETWORK_LOADBALANCER_ID
        iD of the Network Loadbalancer (required)

    forwarding_rule_id: --forwarding-rule FORWARDING_RULE_ID, -R FORWARDING_RULE_ID
        iD of the Network Loadbalancer Forwarding Rule (required)

    ip: --ip IP, -i IP
        iP of a balanced target VM (required)

    port: --port PORT, -p PORT
        port of the balanced target service. (range: 1 to 65535) (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    ionoscloud_url: --url URL
        the Ionoscloud API URL

```
## Example

```text
knife ionoscloud networkloadbalancer rule target remove --extra-config EXTRA_CONFIG_FILE_PATH --datacenter-id DATACENTER_ID --network-loadbalancer NETWORK_LOADBALANCER_ID --forwarding-rule FORWARDING_RULE_ID --ip IP --port PORT --username USERNAME --password PASSWORD --url URL
```
