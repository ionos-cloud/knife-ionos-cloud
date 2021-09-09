# NetworkloadbalancerRuleTargetAdd

Adds a target to a Network Load Balancer Forwarding Rule under a data center.

```text
knife ionoscloud networkloadbalancer rule target add (options)
```

## Available options:

### Required options:

* datacenter\_id
* network\_loadbalancer\_id
* forwarding\_rule\_id
* ip
* port
* weight
* ionoscloud\_username
* ionoscloud\_password

```text
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

    weight: --weight WEIGTH, -w WEIGTH
        weight parameter is used to adjust the target VM's weight relative to other target VMs. All target VMs will receive a load proportional to their weight relative to the sum of all weights, so the higher the weight, the higher the load. The default weight is 1, and the maximal value is 256. A value of 0 means the target VM will not participate in load-balancing but will still accept persistent connections. If this parameter is used to distribute the load according to target VM's capacity, it is recommended to start with values which can both grow and shrink, for instance between 10 and 100 to leave enough room above and below for later adjustments. (required)

    check: --check, -c
        check specifies whether the target VM's health is checked. If turned off, a target VM is always considered available. If turned on, the target VM is available when accepting periodic TCP connections, to ensure that it is really able to serve requests. The address and port to send the tests to are those of the target VM. The health check only consists of a connection attempt.

    check_interval: --check-interval CHECK_INTERVAL
        checkInterval determines the duration (in milliseconds) between consecutive health checks. If unspecified a default of 2000 ms is used.

    maintenance: --maintenance MAINTENANCE, -m
        maintenance specifies if a target VM should be marked as down, even if it is not.

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

```
## Example

```text
knife ionoscloud networkloadbalancer rule target add --datacenter-id DATACENTER_ID --network-loadbalancer NETWORK_LOADBALANCER_ID --forwarding-rule FORWARDING_RULE_ID --ip IP --port PORT --weight WEIGTH --check --check-interval CHECK_INTERVAL --maintenance MAINTENANCE --username USERNAME --password PASSWORD --extra-config EXTRA_CONFIG_FILE_PATH
```
